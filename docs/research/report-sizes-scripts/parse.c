// Baseline: how fast can a plain native program parse and merge line coverage?
// Formats: lcov (SF/DA), go (coverprofile, blocks expanded to lines), cob (Cobertura <class filename> / <line number hits>).
// Records go into flat arrays (file_id, line, hits); paths are interned. Merge = sort by (file,line) and sum hits.
// usage: parse <lcov|go|cob> files...
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <time.h>

typedef struct { uint64_t key; uint64_t hits; } Rec;
static Rec *recs; static size_t nrec, caprec;
static char **names; static uint32_t nnames;
static uint32_t *tab; static size_t tabcap = 1<<16; // open addressing, stores id+1

static double now(void){ struct timespec t; clock_gettime(CLOCK_MONOTONIC,&t); return t.tv_sec+t.tv_nsec/1e9; }
static uint64_t fnv(const char*s,size_t n){ uint64_t h=1469598103934665603ULL; for(size_t i=0;i<n;i++){h^=(unsigned char)s[i];h*=1099511628211ULL;} return h; }
static void grow(void){ size_t oc=tabcap; uint32_t*ot=tab; tabcap*=2; tab=calloc(tabcap,4);
  for(size_t i=0;i<oc;i++) if(ot[i]){ const char*s=names[ot[i]-1]; size_t j=fnv(s,strlen(s))&(tabcap-1); while(tab[j]) j=(j+1)&(tabcap-1); tab[j]=ot[i]; } free(ot); }
static uint32_t intern(const char*s,size_t n){
  if(nnames*2>=tabcap) grow();
  size_t j=fnv(s,n)&(tabcap-1);
  while(tab[j]){ const char*t=names[tab[j]-1]; if(strlen(t)==n && !memcmp(t,s,n)) return tab[j]-1; j=(j+1)&(tabcap-1); }
  if((nnames&(nnames-1))==0) names=realloc(names,sizeof(char*)*(nnames?nnames*2:1));
  char*c=malloc(n+1); memcpy(c,s,n); c[n]=0; names[nnames]=c; tab[j]=++nnames; return nnames-1; }
static inline void add(uint32_t f,uint32_t line,uint64_t h){
  if(nrec==caprec){ caprec=caprec?caprec*2:1<<20; recs=realloc(recs,caprec*sizeof(Rec)); }
  recs[nrec].key=((uint64_t)f<<32)|line; recs[nrec].hits=h; nrec++; }
static inline uint64_t num(const char**p){ uint64_t v=0; while(**p>='0'&&**p<='9'){ v=v*10+(**p-'0'); (*p)++; } return v; }

static void parse_lcov(const char*p,const char*e){
  uint32_t f=0;
  while(p<e){ const char*nl=memchr(p,'\n',e-p); if(!nl) nl=e;
    if(p[0]=='S'&&p[1]=='F'&&p[2]==':') f=intern(p+3,nl-p-3);
    else if(p[0]=='D'&&p[1]=='A'&&p[2]==':'){ const char*q=p+3; uint64_t ln=num(&q); q++; add(f,(uint32_t)ln,num(&q)); }
    p=nl+1; } }
static void parse_go(const char*p,const char*e){
  p=memchr(p,'\n',e-p)+1; // mode line
  while(p<e){ const char*nl=memchr(p,'\n',e-p); if(!nl) nl=e;
    const char*c=nl; while(*c!=':') c--; // last ':' before range
    uint32_t f=intern(p,c-p); const char*q=c+1;
    uint64_t sl=num(&q); q++; num(&q); q++; uint64_t el=num(&q); q++; num(&q); q++; num(&q); q++; uint64_t cnt=num(&q);
    for(uint64_t l=sl;l<=el;l++) add(f,(uint32_t)l,cnt);
    p=nl+1; } }
static const char* find(const char*p,const char*e,const char*s,size_t n){ return memmem(p,e-p,s,n); }
static void parse_cob(const char*p,const char*e){
  uint32_t f=0;
  for(;;){ const char*lt=memchr(p,'<',e-p); if(!lt) break; p=lt+1;
    if(!strncmp(p,"class ",6)){ const char*a=find(p,e,"filename=\"",10)+10; const char*b=memchr(a,'"',e-a); f=intern(a,b-a); p=b; }
    else if(!strncmp(p,"line ",5)){ const char*a=find(p,e,"number=\"",8)+8; uint64_t ln=num(&a); const char*h=find(a,e,"hits=\"",6)+6; add(f,(uint32_t)ln,num(&h)); p=h; } } }

static int cmp(const void*a,const void*b){ uint64_t x=((Rec*)a)->key,y=((Rec*)b)->key; return x<y?-1:x>y; }
int main(int argc,char**argv){
  tab=calloc(tabcap,4); size_t bytes=0; double t0=now();
  for(int i=2;i<argc;i++){ int fd=open(argv[i],O_RDONLY); struct stat st; fstat(fd,&st); bytes+=st.st_size;
    const char*m=mmap(0,st.st_size,PROT_READ,MAP_PRIVATE,fd,0);
    if(!strcmp(argv[1],"lcov")) parse_lcov(m,m+st.st_size); else if(!strcmp(argv[1],"go")) parse_go(m,m+st.st_size); else parse_cob(m,m+st.st_size);
    munmap((void*)m,st.st_size); close(fd); }
  double t1=now();
  qsort(recs,nrec,sizeof(Rec),cmp); size_t out=0;
  for(size_t i=0;i<nrec;i++){ if(out&&recs[out-1].key==recs[i].key) recs[out-1].hits+=recs[i].hits; else recs[out++]=recs[i]; }
  size_t cov=0; for(size_t i=0;i<out;i++) cov+=recs[i].hits>0;
  double t2=now();
  printf("inputs=%d bytes=%zu files=%u records=%zu merged_lines=%zu covered=%zu parse=%.3fs (%.0f MB/s) merge=%.3fs\n",
    argc-2,bytes,nnames,nrec,out,cov,t1-t0,bytes/1e6/(t1-t0),t2-t1);
  return 0; }
