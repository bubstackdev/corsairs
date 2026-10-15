import subprocess,json,sys,time
from pathlib import Path
root=Path('/private/tmp/corsairs-large-fence-diagnostic');root.mkdir(exist_ok=True)
base=['fixtures/parity-v03/large-tensors/h3-rgb345/model.aimodel','float32','345,1344,768,3']
commands=[('swift-dictionary-fast-gpu',['/private/tmp/corsairs-large-swift-dictionary-fast',*base,'gpu-preferred','h3-rgb345',str(root/'swift-gpu.json')],90),('swift-dictionary-fast-cpu',['/private/tmp/corsairs-large-swift-dictionary-fast',*base,'cpu','h3-rgb345',str(root/'swift-cpu.json')],90),('metal-only-gpu',['/private/tmp/corsairs-large-metal-only',*base,'gpu-preferred'],120)]
results=[]
for name,args,limit in commands:
    start=time.monotonic()
    with (root/(name+'.stdout')).open('w') as out,(root/(name+'.stderr')).open('w') as err:
        try:r=subprocess.run(args,stdout=out,stderr=err,timeout=limit);status=r.returncode
        except subprocess.TimeoutExpired:status='timeout'
    results.append(dict(name=name,command=args,exit_status=status,seconds=time.monotonic()-start,stdout=(root/(name+'.stdout')).read_text(),stderr=(root/(name+'.stderr')).read_text()))
    (root/'results.json').write_text(json.dumps(results,indent=2)+'\n')
    print(name,status,flush=True)
