import {useApp} from './store';
import {O} from './data';
import {Pic,byId,IMK} from './helpers';
import {CATS,DESC} from './catalog';
import RAT from './ratings.json';

/* Rating from the ratings file; other items get a steady value worked out from the name */
const hash=(s:string)=>{let h=0;for(const c of s)h=(h*31+c.charCodeAt(0))>>>0;return h};
export function rating(k:string){
  const r=(RAT as any)[IMK[k]];
  if(r)return {r:r.rating as number,n:r.reviews as number};
  const h=hash(k);return {r:4+(h%8)/10,n:20+(Math.floor(h/8)%101)};
}
export const firstVillage=(k:string)=>(byId[k]?byId[k].v:(O as any[]).find(o=>o.n===k)?.v||[[ 'Ambaee' ]])[0][0] as string;
export const priceOf=(k:string)=>byId[k]?<>&#8377;{byId[k].p} / {byId[k].u}</>:<>Price on request</>;

export function Stars({r}:{r:number}){
  const h=Math.round(r*2)/2;
  return <span className="stars" aria-label={`${h} out of 5`}>{[0,1,2,3,4].map(i=><span key={i} className="s1">&#9733;<span style={{width:h>=i+1?'100%':h>=i+.5?'50%':'0'}}>&#9733;</span></span>)}</span>;
}

/* One card for every resource. k is a product id or a sapling name; v is the Gram Sabha. */
export default function ResCard({k,v}:{k:string,v?:string}){
  const a=useApp(),p=byId[k],o=(O as any[]).find(x=>x.n===k);
  if(!p&&!o)return null;
  const vn=v||firstVillage(k),rt=rating(k),wk=`${k}|${vn}`,saved=a.wish.includes(wk); /* saved per Gram Sabha */
  return <div className="rc" onClick={()=>a.openP(k,v)}>
    <div className="im"><Pic k={k} kind={p?p.k:'sap'} col={p?p.c:'#9CCB6B'}/>
      <button type="button" className={`wb${saved?' on':''}`} aria-label={saved?'Remove from Wishlist':'Save to Wishlist'} aria-pressed={saved} onClick={e=>{e.stopPropagation();a.toggleWish(wk)}}>{saved?'★':'☆'}</button></div>
    <div className="nm">{p?p.n:k}</div>
    <div className="rd">{p?p.a:DESC[k]||'Sold as saplings'}</div>
    <div className="rs"><Stars r={rt.r}/><span>({rt.n})</span></div>
    <div className="rf"><div className="pc">{priceOf(k)}</div>
      <button type="button" className="pl" aria-label={`Add ${p?p.n:k} to cart`} onClick={e=>{e.stopPropagation();a.addCart(k,vn)}}><i className="ti ti-plus"></i></button></div>
  </div>;
}

export function CategoryBoxes(){
  return <div className="cats">{CATS.map(([t,ks])=><div key={t} className="cb"><h3>{t}</h3><div className="g2c">{ks.map(k=><ResCard key={k} k={k}/>)}</div></div>)}</div>;
}
