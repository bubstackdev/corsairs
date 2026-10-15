#!/usr/bin/env python3
"""Build, but never execute, application Metal interoperability evidence."""
from pathlib import Path
import argparse
import hashlib
import json
import subprocess

ROOT=Path(__file__).resolve().parents[1]


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--release',action='store_true')
    args=parser.parse_args(); profile='release' if args.release else 'debug'
    output=ROOT/'target/metal-app'/profile; output.mkdir(parents=True,exist_ok=True)
    source=ROOT/'experiments/c/MetalApplicationKernel.m'
    driver=ROOT/'experiments/rust/metal_app_kernel.rs'
    library=output/'libmetal-app.dylib'; binary=output/'metal-app-kernel'
    build=['cargo','build','--offline','-p','corsairs','--lib']
    if args.release:build.append('--release')
    commands=[build,['xcrun','clang','-dynamiclib','-fobjc-arc','-O2','-framework','Foundation','-framework','Metal',str(source),'-o',str(library)],['rustc','--edition=2024',str(driver),'--extern',f'corsairs={ROOT}/target/{profile}/libcorsairs.rlib','-L',f'dependency={ROOT}/target/{profile}/deps','-o',str(binary)]]
    if args.release:commands[-1].extend(['-C','opt-level=3'])
    results=[]
    for command in commands:
        result=subprocess.run(command,cwd=ROOT,text=True,capture_output=True)
        results.append({'command':command,'exit_code':result.returncode,'stdout':result.stdout,'stderr':result.stderr})
        print(result.stderr,end='')
        if result.returncode:raise SystemExit(result.returncode)
    files=sorted((ROOT/'crates/corsairs-abi/src').rglob('*.rs'))+[source,driver,Path(__file__),library,binary]
    record={'native_executed':False,'production_links_helper':False,'profile':profile,'files_sha256':{str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in files},'commands':results}
    (output/'build.json').write_text(json.dumps(record,indent=2)+'\n')
    print(binary);print(library)


if __name__=='__main__':main()
