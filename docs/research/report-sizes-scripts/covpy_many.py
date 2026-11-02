# Make N distinct coverage.py data files, each a random 50% sample of the executed lines of one real HA shard.
import sys, os, random, sqlite3
sys.path.insert(0, os.path.dirname(__file__))
from coverage import CoverageData
src, out, n = sys.argv[1], sys.argv[2], int(sys.argv[3]); os.makedirs(out, exist_ok=True)
shards=[f for f in os.listdir(src) if f.startswith('.coverage.')]
data={}
for s in shards:
    d=CoverageData(basename=os.path.join(src,s)); d.read(); data[s]={f:list(d.lines(f)) for f in d.measured_files()}
rnd=random.Random(1)
for i in range(n):
    s=shards[i%len(shards)]; lines={f:[l for l in ls if rnd.random()<0.5] for f,ls in data[s].items()}
    d=CoverageData(basename=os.path.join(out,f'.coverage.{i}')); d.add_lines(lines); d.write()
