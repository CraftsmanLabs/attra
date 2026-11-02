# Convert real reports into other formats so each tool can be benchmarked on real shapes.
# usage: convert.py ha <shard_dir_root> <outdir>   |  convert.py go <coverprofile> <outdir> <nshards>
import sys, os, json, xml.etree.ElementTree as ET
from collections import defaultdict

def ha_shards(root):
    for d in sorted(os.listdir(root)):
        p=os.path.join(root,d,'coverage.xml')
        src=None; files={}
        for ev,el in ET.iterparse(p, events=('end',)):
            if el.tag=='source': src=el.text.strip()
            elif el.tag=='class':
                path=os.path.relpath(os.path.join(src,el.get('filename')),'/home/runner/work/core/core')
                files[path]={int(l.get('number')):int(l.get('hits')) for l in el.iter('line')}
                el.clear()
        yield d, files

def write_lcov(path, files):
    with open(path,'w') as f:
        for name,lines in files.items():
            f.write(f"TN:\nSF:/src/{name}\n")
            for n in sorted(lines): f.write(f"DA:{n},{lines[n]}\n")
            f.write(f"LF:{len(lines)}\nLH:{sum(1 for v in lines.values() if v)}\nend_of_record\n")

def write_istanbul(path, files):
    out={}
    for name,lines in files.items():
        fn='/src/'+name; ks=sorted(lines)
        out[fn]={'path':fn,'statementMap':{str(i):{'start':{'line':n,'column':0},'end':{'line':n,'column':80}} for i,n in enumerate(ks)},
                 's':{str(i):lines[n] for i,n in enumerate(ks)},'fnMap':{},'f':{},'branchMap':{},'b':{}}
    json.dump(out,open(path,'w'))

def write_cobertura(path, files):
    with open(path,'w') as f:
        f.write('<?xml version="1.0" ?>\n<coverage version="x" line-rate="0" branch-rate="0" lines-covered="0" lines-valid="0" branches-covered="0" branches-valid="0" complexity="0" timestamp="0">\n<sources><source>/src</source></sources>\n<packages><package name="p" line-rate="0" branch-rate="0" complexity="0"><classes>\n')
        for name,lines in files.items():
            f.write(f'<class name="{name}" filename="{name}" line-rate="0" branch-rate="0" complexity="0"><methods/><lines>\n')
            for n in sorted(lines): f.write(f'<line number="{n}" hits="{lines[n]}"/>\n')
            f.write('</lines></class>\n')
        f.write('</classes></package></packages></coverage>\n')

def write_covpy(path, files):
    from coverage import CoverageData
    d=CoverageData(basename=path); d.add_lines({'/src/'+k:[n for n,h in v.items() if h] for k,v in files.items()}); d.write()

def go_files(p):
    files=defaultdict(dict); blocks=defaultdict(list)
    with open(p) as f:
        mode=f.readline()
        for line in f:
            name,rest=line.rsplit(':',1)  # name:sl.sc,el.ec nstmt count
            rng,nst,cnt=rest.split(); a,b=rng.split(','); sl=int(a.split('.')[0]); el=int(b.split('.')[0]); c=int(cnt)
            blocks[name].append(line)
            for n in range(sl,el+1): files[name][n]=max(files[name].get(n,0),c)
    return mode,files,blocks

if __name__=='__main__':
    kind,src,out=sys.argv[1:4]; os.makedirs(out,exist_ok=True)
    if kind=='ha':
        for d,files in ha_shards(src):
            write_lcov(f'{out}/{d}.info',files); write_istanbul(f'{out}/{d}.json',files)
            write_cobertura(f'{out}/{d}.xml',files); write_covpy(f'{out}/.coverage.{d}',files)
    else:
        mode,files,blocks=go_files(src); n=int(sys.argv[4])
        write_lcov(f'{out}/k8s.info',files); write_istanbul(f'{out}/k8s.json',files); write_cobertura(f'{out}/k8s.xml',files)
        print('go files',len(files),'lines',sum(len(v) for v in files.values()),'covered',sum(1 for v in files.values() for c in v.values() if c))
        names=sorted(blocks)
        for i in range(n):
            with open(f'{out}/k8s-shard{i}.out','w') as f:
                f.write(mode); [f.writelines(blocks[x]) for x in names[i::n]]
