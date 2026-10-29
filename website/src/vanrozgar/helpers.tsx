import {useState} from 'react';
import {P,R,IM,TAL} from './data';

export const NQ='Quantity not entered yet',NC='Count not available',APK_URL:string='https://github.com/VANMITRA/VanRojgar_final_module/releases/download/website-apk/VanMitra.apk'
export const nf=(n:number|string)=>Number(n).toLocaleString('en-US');
export const loc=(v:string)=>`${v}, ${TAL[v]||'Trimbakeshwar'}, Nashik`;
export const byId:Record<string,any>=Object.fromEntries(P.map((p:any)=>[p.i,p]));
export const VIL:string[]=Object.keys(R);
export const TOP=['bamboo','moh','tamarind','awla','cashew','mango','behda','hirda','custard','jamun','bael','ber','karanj'];
export const CIR=['bamboo','behda','cashew','tamarind','moh','mango','custard','awla'];
export const CAT:Record<string,string>={bamboo:'Bamboo',tamarind:'Fruit',awla:'Fruit',mango:'Fruit',custard:'Fruit',jamun:'Fruit',bael:'Fruit',ber:'Fruit',moh:'Nuts, seeds, flowers',cashew:'Nuts, seeds, flowers',karanj:'Nuts, seeds, flowers',behda:'Dry fruit and herbs',hirda:'Dry fruit and herbs'};
export const S:Record<string,any[]>={};VIL.forEach(v=>S[v]=[]);TOP.forEach(id=>byId[id].v.forEach((r:any)=>S[r[0]].push([id,r[2]])));
export const RN:Record<string,string>={gs:'Gram Sabha member',vil:'CFR villager',buy:'General buyer',drv:'Delivery partner'};
/* Barter is hidden on the main site. It returns only inside the Gram Sabha member login. */
export const SHOW_BARTER=false;
export const NAV=[['','Home'],['resources','Resources'],['gram-sabhas','Gram Sabhas'],['barter','Barter'],['deliver','Deliver with us'],['impact','Our impact']].filter(n=>SHOW_BARTER||n[0]!=='barter');

/* Columns so the last row is never half empty: the largest divisor of n that fits, else the last row stretches */
const pick=(n:number,max:number)=>{for(let d=Math.min(max,n);d>=2;d--)if(n%d===0)return d;return max};
export const fgs=(n:number):any=>({'--cw':pick(n,5),'--ct':pick(n,3),'--cp':pick(n,2)});
export const sum=(i:number)=>VIL.reduce((a,v)=>a+R[v][i+1],0); /* R[v][0] is the block name */
export const IMK:Record<string,string>=IM;
export const unit=(id:string)=>!byId[id]?'trees':byId[id].u==='kg'?'kg':'poles';
export const prod=(id:string)=>byId[id]||{i:id,n:id,pr:id+' saplings',k:'sap',c:'#9CCB6B',p:0,u:'tree',v:[] as any[]};

export function PlantSvg({kind,col}:{kind:string,col?:string}){
  const c=col||'#9CCB6B';
  return <svg viewBox="0 0 100 90" aria-hidden="true"><rect width="100" height="90" fill="#E4EDCB"/><path d="M14 72v8a36 8 0 0 0 72 0v-8z" fill="#CDB892"/><ellipse cx="50" cy="72" rx="36" ry="8" fill="#E8DABB"/><path d="M34 56h32l-4 16H38z" fill="#A9693C"/><rect x="32" y="52" width="36" height="6" rx="2" fill="#C0804D"/>
    {kind==='bamboo'?<><rect x="41" y="8" width="5" height="46" fill="#8DB85A"/><rect x="50" y="14" width="5" height="40" fill="#7FA84C"/><rect x="59" y="10" width="5" height="44" fill="#8DB85A"/><ellipse cx="36" cy="14" rx="9" ry="3" fill="#6FA24A" transform="rotate(-25 36 14)"/><ellipse cx="68" cy="16" rx="9" ry="3" fill="#6FA24A" transform="rotate(25 68 16)"/></>
    :<><rect x="48" y="30" width="4" height="24" fill="#7B5232"/><circle cx="50" cy="22" r="16" fill="#6FA24A"/><circle cx="37" cy="31" r="11" fill="#86B85C"/><circle cx="63" cy="31" r="11" fill="#86B85C"/><circle cx="42" cy="24" r="3.2" fill={c}/><circle cx="57" cy="19" r="3.2" fill={c}/><circle cx="50" cy="31" r="3.2" fill={c}/></>}
  </svg>;
}

export function Pic({k,kind,col}:{k:string,kind:string,col?:string}){
  const [bad,setBad]=useState(false);
  const f=IM[k]&&!bad;
  return f?<img src={`assets/resources/${IM[k]}.jpg`} alt="" loading="lazy" decoding="async" onError={()=>setBad(true)}/>:<PlantSvg kind={kind} col={col}/>;
}

export const Chips=({list,sel,onPick}:{list:string[],sel:string,onPick:(c:string)=>void})=>
  <>{list.map(c=><span key={c} className={`fc${c===sel?' on':''}`} onClick={()=>onPick(c)}>{c}</span>)}</>;
export const Kv=({a,b}:{a:any,b:any})=><div className="kv"><span>{a}</span><span>{b}</span></div>;
export const Tile=({x}:{x:any[]})=><div className="st"><div className="big">{x[0]}</div><div><b>{x[1]}</b></div><div className="meaning">{x[2]||''}</div></div>;
export const Foot=(_:{s?:string})=>null; /* the big footer is in SiteFooter */
