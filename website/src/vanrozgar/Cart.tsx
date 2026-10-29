import {useApp} from './store';
import {Foot,Pic,prod,unit} from './helpers';
import {costText,today} from './requests/common';
import {Price} from './Card';
import {Req} from './requests/mock';
import {useT} from './i18n';

export default function Cart(){const t=useT();
  const a=useApp();
  const vs=Array.from(new Set(a.cart.map(x=>x.v)));
  const step=(k:string,v:string,d:number)=>a.setCart(c=>c.map(x=>x.k===k&&x.v===v?{...x,n:Math.max(1,x.n+d)}:x));
  const del=(k:string,v:string)=>a.setCart(c=>c.filter(x=>!(x.k===k&&x.v===v)));
  /* TODO: send the requests to the server */
  const send=(v:string)=>{
    if(a.role==='out'){a.toast(t("Log in to send a request."));location.hash='#/login';return}
    const lines=a.cart.filter(x=>x.v===v),need=new Date(Date.now()+7*864e5).toISOString().slice(0,10);
    a.setReqs(prev=>{let n=Math.max(0,...prev.map(r=>+r.id.slice(3)));
      const add:Req[]=lines.map(x=>({id:'VR-'+String(++n).padStart(4,'0'),p:x.k,v,qty:x.n,st:'pending',d:new Date().toLocaleDateString('en-GB',{day:'numeric',month:'short',year:'numeric'}),why:'My own use',how:'Pick up',need:need>today()?need:today()}));
      return [...add.reverse(),...prev]});
    a.setCart(c=>c.filter(x=>x.v!==v));
    a.toast(t('Request sent to the {village} Gram Sabha.',{village:v}));location.hash='#/account/requests';
  };
  return <div className="rq-page">
    <h1>{t("Cart")}</h1><div className="sub">{t("Your items, grouped by Gram Sabha. Each Gram Sabha gets its own request.")}</div>
    {vs.length?vs.map(v=><div key={v} className="rq-card" style={{marginBottom:12}}>
      <h2 style={{fontSize:16}}>{t("{village} Gram Sabha",{village:v})}</h2>
      {a.cart.filter(x=>x.v===v).map(x=>{const p=prod(x.k);return <div key={x.k} className="cl">
        <div className="mini" style={{width:56,flex:'0 0 56px'}}><Pic k={x.k} kind={p.k} col={p.c}/></div>
        <div style={{flex:1,minWidth:0}}><div className="nm">{t(p.n)}</div><div className="lc"><Price k={x.k}/></div></div>
        <div className="qs"><button type="button" aria-label={t("Less")} onClick={()=>step(x.k,v,-1)}>&minus;</button><span>{x.n} {t(unit(x.k))}</span><button type="button" aria-label={t("More")} onClick={()=>step(x.k,v,1)}>+</button></div>
        <div className="nm" style={{minWidth:70,textAlign:'right'}}>{costText(x.k,x.n,t)}</div>
        <button type="button" className="ib" aria-label={t('Remove {name}',{name:t(p.n)})} onClick={()=>del(x.k,v)}><i className="ti ti-trash"></i></button></div>})}
      <button type="button" className="b1 rq-full" onClick={()=>send(v)}>{t("Send request")}</button>
      <div className="rq-hint" style={{textAlign:'center',marginTop:8}}>{t("No payment now. The Gram Sabha confirms the final amount.")}</div>
    </div>)
    :<div className="rq-card" style={{textAlign:'center'}}><div style={{color:'var(--mut)',marginBottom:10}}>{t("Your cart is empty.")}</div><button type="button" className="b1" onClick={()=>{location.hash='#/resources'}}>{t("Browse resources")}</button></div>}
    <Foot/>
  </div>;
}
