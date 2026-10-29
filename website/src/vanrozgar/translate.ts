/* Runtime translator. English text rendered by React is swapped for the chosen language by looking it up in ./dict.
   Numbers are matched as {n}; {w} in a key is a slot that is itself translated (for example a plant name).
   Original English is kept per node, so switching language (or back to English) always starts from the source text. */
import type {Lang} from './lang';
import {build} from './dict';

const ATTRS=['placeholder','aria-label','title','alt'];
const SKIP=new Set(['SCRIPT','STYLE','TEXTAREA','CODE']);
const NUM=/\d[\d,]*(?:\.\d+)?/g;
const LEAD=/^[\s·›‹\-–—,:;.(]+/;
const TRAIL=/[\s·›‹\-–—,:;.)!?]+$/;

type Rec={o:string,s:string};
/* Kept on window so a hot reload cannot leave an old copy of this module translating the page. */
const G=window as any;
const tmap:WeakMap<Text,Rec>=G.__vrTmap||(G.__vrTmap=new WeakMap());
const amap:WeakMap<Element,Record<string,Rec>>=G.__vrAmap||(G.__vrAmap=new WeakMap());
let lang:Lang='en',root:Element|null=null,obs:MutationObserver|null=null,raf=0;
let D=build('hi');

const norm=(s:string)=>{const n:string[]=[];return {k:s.replace(NUM,m=>{n.push(m);return '{n}'}),n}};
const fill=(t:string,n:string[])=>{let i=0;return t.replace(/\{n\}/g,()=>n[i++]??'')};

function tr(s:string,depth=0):string|null{
  const {k,n}=norm(s);
  const hit=D.exact.get(k);
  if(hit!==undefined)return fill(hit,n);
  for(const sl of D.slots){
    const m=sl.re.exec(s.trim());
    if(!m)continue;
    const ws:string[]=[],ns:string[]=[];
    sl.kinds.forEach((kind,i)=>(kind==='{w}'?ws:ns).push(m[i+1]));
    let wi=0,ni=0;
    return sl.t.replace(/\{w\}|\{n\}/g,x=>{
      if(x==='{n}')return ns[ni++]??'';
      const w=ws[wi++]??'';
      return tr(w,depth+1)??w;
    });
  }
  if(depth<3)for(const sep of [' · ',', ',' / ',' and ']){
    if(!k.includes(sep))continue;
    let any=false;
    const parts=s.split(sep).map(p=>{const r=tr(p,depth+1);if(r!==null)any=true;return r??p});
    if(any)return parts.join(sep);
  }
  return null;
}

function translate(raw:string):string|null{
  const core=raw.trim();
  if(!core||!/[A-Za-z]/.test(core))return null;
  const a=raw.slice(0,raw.indexOf(core)),b=raw.slice(raw.indexOf(core)+core.length);
  const t=tr(core);
  if(t!==null)return a+t+b;
  /* Retry without leading or trailing punctuation, e.g. "· Deola", "Fencing and farm structures." */
  const lead=core.match(LEAD)?.[0]??'',trail=core.slice(lead.length).match(TRAIL)?.[0]??'';
  const inner=core.slice(lead.length,core.length-trail.length);
  if(!inner||(!lead&&!trail))return null;
  const t2=tr(inner);
  return t2===null?null:a+lead+t2+trail+b;
}

function doRun(run:Text[]){
  const recs=run.map(n=>{let r=tmap.get(n);if(!r||n.data!==r.s){r={o:n.data,s:n.data};tmap.set(n,r)}return r});
  const put=(n:Text,r:Rec,v:string)=>{if(n.data!==v)n.data=v;r.s=v};
  if(lang==='en'){run.forEach((n,i)=>put(n,recs[i],recs[i].o));return}
  const joined=recs.map(r=>r.o).join('');
  const t=run.length>1?translate(joined):null;
  if(t!==null){run.forEach((n,i)=>put(n,recs[i],i===0?t:''));return}
  run.forEach((n,i)=>{const x=translate(recs[i].o);put(n,recs[i],x??recs[i].o)});
}

function doAttrs(el:Element){
  for(const a of ATTRS){
    const cur=el.getAttribute(a);
    if(cur===null)continue;
    const m=amap.get(el)||{};amap.set(el,m);
    let r=m[a];
    if(!r||cur!==r.s){r={o:cur,s:cur};m[a]=r}
    const v=lang==='en'?r.o:(translate(r.o)??r.o);
    if(v!==cur)el.setAttribute(a,v);
    r.s=v;
  }
}

function visit(el:Element){
  if(SKIP.has(el.tagName))return;
  doAttrs(el);
  let run:Text[]=[];
  const flush=()=>{if(run.length){doRun(run);run=[]}};
  for(const c of Array.from(el.childNodes)){
    if(c.nodeType===3)run.push(c as Text);
    else{flush();if(c.nodeType===1)visit(c as Element)}
  }
  flush();
}

function scan(){
  raf=0;
  if(!root)return;
  obs?.disconnect();
  visit(root);
  obs?.observe(root,{childList:true,subtree:true,characterData:true,attributes:true,attributeFilter:ATTRS});
}
const queue=()=>{if(!raf)raf=requestAnimationFrame(scan)};

/* Call whenever the language changes. Passing 'en' restores the original text. */
export function applyLang(l:Lang,el:Element|null){
  lang=l;root=el;
  if(l!=='en')D=build(l);
  if(!el)return;
  G.__vrObs?.disconnect();
  obs=G.__vrObs=new MutationObserver(queue);
  scan();
  if(l==='en'){obs.disconnect()}
}

/* For code that needs a translated string directly (toasts, titles). */
export const trText=(l:Lang,s:string)=>{if(l==='en')return s;D=build(l);return translate(s)??s};
