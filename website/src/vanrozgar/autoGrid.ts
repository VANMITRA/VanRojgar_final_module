import {useEffect} from 'react';

/* One shared grid helper for every group of cards on the site.
   For n cards it picks the columns so the last row is never half empty:
   the largest divisor of n that fits (up to 5 wide, 3 tablet, 2 phone).
   If n has no good divisor, it uses the best fit and the last row stretches. */
const GAP=16;
const SEL='.g2,.g3,.g4,.g5,.g8,.fg,.g2c,.cats';

export function pickCols(n:number,w:number,vw:number,minW:number){
  const cap=vw>=1100?5:vw>=700?3:2;
  const fit=Math.max(1,Math.floor((w+GAP)/(minW+GAP)));
  const max=Math.max(1,Math.min(cap,fit,n));
  if(max===1)return 1;
  for(let c=max;c>=2;c--)if(n%c===0&&c>=Math.ceil(max/2))return c;
  let best=max,score=-1;
  for(let c=max;c>=Math.ceil(max/2);c--){const s=n%c||c;if(s>score){score=s;best=c}}
  return best;
}

function apply(root:ParentNode){
  const vw=innerWidth;
  root.querySelectorAll<HTMLElement>(SEL).forEach(el=>{
    const n=Array.from(el.children).filter(c=>(c as HTMLElement).offsetParent!==null||getComputedStyle(c).position==='fixed').length||el.children.length;
    if(!n)return;
    const minW=el.classList.contains('cats')?300:el.classList.contains('g2c')?150:vw>=1100?220:vw>=700?190:150;
    el.classList.add('ag');
    el.style.setProperty('--c',String(pickCols(n,el.clientWidth,vw,minW)));
  });
}

export function useAutoGrid(){
  useEffect(()=>{
    const root=document.querySelector('.vr');if(!root)return;
    let raf=0;
    const run=()=>{cancelAnimationFrame(raf);raf=requestAnimationFrame(()=>apply(root))};
    const mo=new MutationObserver(run);mo.observe(root,{childList:true,subtree:true});
    addEventListener('resize',run);run();
    return()=>{mo.disconnect();removeEventListener('resize',run);cancelAnimationFrame(raf)};
  },[]);
}
