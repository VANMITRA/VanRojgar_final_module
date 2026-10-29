import {ReactNode,useEffect,useState} from 'react';
import {useApp} from './store';
import {O,P} from './data';
import {TAL} from './data';
import details from './resourceDetails.json';
import {CategoryBoxes} from './Card';
import {Pic,S,tv,TOP,VIL,NQ,byId,nf,unit} from './helpers';
import {PACKS,useLang,useT} from './i18n';

/* The details come in the chosen language. A missing translation falls back to English. */
const det=(lang:string,k:string)=>PACKS[lang as 'en'].details?.[k]??DETAILS[k];
const DETAILS:Record<string,any>=Object.fromEntries((details as any[]).map(d=>[d.id,d]));
function Shell({children,cls=''}:{children:ReactNode,cls?:string}){const t=useT();
  const a=useApp();const close=()=>a.setModal(null);
  useEffect(()=>{const f=(e:KeyboardEvent)=>{if(e.key==='Escape')close()};document.addEventListener('keydown',f);return()=>document.removeEventListener('keydown',f)});
  return <div className="ov" onClick={e=>{if(e.target===e.currentTarget)close()}}><div className={`md${cls}`}><button className="x" aria-label={t("Close")} onClick={close}><i className="ti ti-x"></i></button>{children}</div></div>;
}
const Done=({title,children,chip}:{title:string,children:ReactNode,chip?:ReactNode})=>{const t=useT();
  const a=useApp();
  return <div style={{textAlign:'center',padding:'12px 4px'}}><div className="ic" style={{margin:'0 auto 10px',width:46,height:46,fontSize:26}}><i className="ti ti-circle-check"></i></div><h2>{title}</h2>{chip}<p>{children}</p><button className="b1" style={{width:'100%',justifyContent:'center'}} onClick={()=>a.setModal(null)}>{t("Done")}</button></div>;
};

function PlantModal({k,vn}:{k:string,vn?:string}){const t=useT(),{lang}=useLang();
  const a=useApp();const [all,setAll]=useState(false);
  const p=byId[k],o=p?null:O.find((x:any)=>x.n===k);const rows=(p?p.v:o.v).slice();
  const i=rows.findIndex((r:any)=>r[0]===vn);if(i>0)rows.unshift(rows.splice(i,1)[0]);
  const title=t(p?p.n:o.n),d=det(lang,k);
  return <Shell cls=" pm">
    <div className="pm-h"><div className="row" style={{flexWrap:'nowrap',paddingRight:28}}><div className="mini" style={{width:84,flex:'0 0 84px',borderRadius:12}}><Pic k={k} kind={p?p.k:'sap'} col={p?p.c:'#9CCB6B'}/></div><div><h2 style={{fontSize:20}}>{title}</h2><div className="lc">{p?t(p.pr):t("Sold as saplings")}</div>{p?<div style={{marginTop:4}}><b style={{fontSize:17,color:'var(--or)'}}>&#8377;{p.p} / {tv(p.u,t)}</b></div>:<div style={{marginTop:4,color:'var(--or)',fontWeight:500}}>{t("Price on request")}</div>}</div></div></div>
    <div className="pm-b">
      <div className="mh">{t("About")}</div>
      <p style={{margin:0}}>{d?d.about:p?t(p.a):t("Planted by the village. Ask the Gram Sabha about saplings.")}</p>
      {d&&<><div className="mh">{t("Key facts")}</div>{d.facts.map((x:string[])=><div key={x[0]} className="pm-f1"><b>{t(x[0])}</b><span>{x[1]}</span></div>)}
        <div className="mh">{t("What you can do with it")}</div><ul className="pm-ul">{d.uses.map((x:string[])=><li key={x[0]}><b>{x[0]}.</b> {x[1]}</li>)}</ul>
        <div className="mh">{t("Good to know")}</div><div className="box warn" style={{margin:0}}>{d.note}</div></>}
      <div className="mh">{t("Villages that have it")}</div>
      <div className="pm-v">{rows.map((r:any,j:number)=>(j<3||all)&&<div key={r[0]} className="pm-r"><div><a className="ul" href={'#/gram-sabha/'+encodeURIComponent(r[0])} onClick={()=>a.setModal(null)}>{r[0]}</a>{r[0]===vn&&<> <span className="tag">{t("On this card")}</span></>}<span className="lc"> · {t(TAL[r[0]]||'Trimbakeshwar')}</span></div><div className="qt" style={{margin:0}}>{tv(r[2]||r[1],t)}</div></div>)}</div>
      {rows.length>3?(!all&&<button type="button" className="ul lnk" onClick={()=>setAll(true)}>{t("Search {name} in other Gram Sabhas",{name:title})}</button>):<div className="lc">{t("Only these Gram Sabhas have it so far.")}</div>}
    </div>
    <div className="pm-f"><button className="b1" style={{width:'100%',justifyContent:'center'}} onClick={()=>{a.setModal(null);location.hash=p?`#/request/${p.i}/${encodeURIComponent(vn||rows[0][0])}`:`#/gram-sabha/${encodeURIComponent(rows[0][0])}`}}>{p?t("Send request"):t("Ask about saplings")}</button></div>
  </Shell>;
}

function ArtModal({k}:{k:string}){const t=useT(),{lang}=useLang();
  const a=useApp(),d=det(lang,k),p=byId[k];
  return <Shell cls=" pm">
    <div className="pm-h"><div className="row" style={{flexWrap:'nowrap',paddingRight:28}}><div className="mini" style={{width:84,flex:'0 0 84px',borderRadius:12}}><Pic k={k} kind={p.k} col={p.c}/></div><div><h2 style={{fontSize:20}}>{d.name}</h2><div className="lc">{t("What it is and how to use it")}</div></div></div></div>
    <div className="pm-b"><div className="mh">{t("About")}</div><p style={{margin:0}}>{d.about}</p>
      <div className="mh">{t("Key facts")}</div>{d.facts.map((x:string[])=><div key={x[0]} className="pm-f1"><b>{t(x[0])}</b><span>{x[1]}</span></div>)}
      <div className="mh">{t("What you can do with it")}</div><ul className="pm-ul">{d.uses.map((x:string[])=><li key={x[0]}><b>{x[0]}.</b> {x[1]}</li>)}</ul>
      <div className="mh">{t("Good to know")}</div><div className="box warn" style={{margin:0}}>{d.note}</div></div>
    <div className="pm-f"><button className="b1" style={{width:'100%',justifyContent:'center'}} onClick={()=>a.openP(k)}>{t("See where to buy {name}",{name:d.name})}</button></div>
  </Shell>;
}

function AllModal(){const t=useT();
  const a=useApp();
  return <Shell><h2>{t("All plants")}</h2><div className="sub">{t("{n} plants. Tap one to see where it grows.",{n:P.length+O.length})}</div><CategoryBoxes/></Shell>;
}

function SwapModal({v,id}:{v?:string,id?:string}){const t=useT();
  const gv=S.Ambaee.map(x=>x[0]),vs=VIL.filter(x=>x!=='Ambaee'&&S[x].some(y=>y[1]!==NQ));
  const [g,setG]=useState(gv[0]),[w,setW]=useState(id||TOP[0]),[sv,setSv]=useState(v||vs[0]),[qg,setQg]=useState(''),[qw,setQw]=useState(''),[note,setNote]=useState(''),[er,setEr]=useState(''),[sent,setSent]=useState<any>(null);
  const send=()=>{const a=+qg,b=+qw;
    if(!(a>0)||!(b>0))return setEr('Enter an amount greater than zero for both products.');if(g===w)return setEr('Choose two different products to swap.');
    setSent({a,b})};
  if(sent)return <Shell><Done title={t("Swap offer sent")}>{t("Your Gram Sabha offers")} {nf(sent.a)} {unit(g)} {t("of")} {byId[g].pr} {t("for")} {nf(sent.b)} {unit(w)} {t("of")} {byId[w].pr} {t("from")} {sv}{t(". The")} {sv} {t("Gram Sabha will review it. You can follow it under Barter requests.")}</Done></Shell>;
  return <Shell><h2>{t("Start a swap")}</h2><div className="sub">{t("Sending as your Gram Sabha")}</div>
    <label htmlFor="sg">{t("I give")}</label><div className="row" style={{flexWrap:'nowrap'}}><select id="sg" value={g} onChange={e=>setG(e.target.value)}>{gv.map(x=><option key={x} value={x}>{byId[x].pr}</option>)}</select><input type="number" min="1" placeholder={t("Amount")} style={{maxWidth:120}} value={qg} onChange={e=>setQg(e.target.value)}/><span className="lc">{unit(g)}</span></div>
    <label htmlFor="sw">{t("I want")}</label><div className="row" style={{flexWrap:'nowrap'}}><select id="sw" value={w} onChange={e=>setW(e.target.value)}>{TOP.map(x=><option key={x} value={x}>{byId[x].pr}</option>)}</select><input type="number" min="1" placeholder={t("Amount")} style={{maxWidth:120}} value={qw} onChange={e=>setQw(e.target.value)}/><span className="lc">{unit(w)}</span></div>
    <label htmlFor="sv">{t("From the Gram Sabha of")}</label><select id="sv" value={sv} onChange={e=>setSv(e.target.value)}>{vs.map(x=><option key={x}>{x}</option>)}</select>
    <label htmlFor="sn">{t("Note (optional)")}</label><input id="sn" placeholder={t("For example: we can pick up on Friday")} value={note} onChange={e=>setNote(e.target.value)}/>
    <div className="err">{er}</div><div className="row"><SendCancel label={t("Send swap offer")} onSend={send}/></div></Shell>;
}
function SendCancel({label,onSend}:{label:string,onSend:()=>void}){const t=useT();
  const a=useApp();
  return <><button className="b1" style={{flex:1,justifyContent:'center'}} onClick={onSend}>{label}</button><button className="b2" onClick={()=>a.setModal(null)}>{t("Cancel")}</button></>;
}

function DrvModal(){const t=useT();
  const [f,setF]=useState({n:'',p:'',t:'',v:'',c:'',l:''}),[er,setEr]=useState(''),[ok,setOk]=useState('');
  const a=useApp();const set=(k:string)=>(e:any)=>setF({...f,[k]:e.target.value});
  const send=()=>{if(!f.n.trim()||!/^[0-9]{10}$/.test(f.p.trim())||!f.t||!f.v.trim()||!(+f.c>0))return setEr('Enter your name, a 10-digit phone number, vehicle type, vehicle number and how much it can carry.');setOk(f.n.trim())};
  if(ok)return <Shell><Done title={t("Application sent")} chip={<span className="chip" style={{background:'var(--tint)',color:'var(--tag)'}}>{t("Waiting for the VanRozgar team")}</span>}>{t("Thank you, {name}. The team will check your details and tell you by SMS. You can follow your status on the Deliver with us page.",{name:ok})}</Done></Shell>;
  return <Shell><h2>{t("Register as a delivery partner")}</h2><div className="sub">{t("The VanRozgar team checks every application.")}</div>
    <label htmlFor="dn">{t("Full name")}</label><input id="dn" value={f.n} onChange={set('n')}/><label htmlFor="dp">{t("Phone number")}</label><input id="dp" type="tel" placeholder={t("10 digits")} value={f.p} onChange={set('p')}/>
    <div className="row" style={{flexWrap:'nowrap'}}><div style={{flex:1}}><label htmlFor="dt">{t("Vehicle type")}</label><select id="dt" value={f.t} onChange={set('t')}><option value="">{t("Choose")}</option><option>{t("Auto")}</option><option>{t("Pick-up")}</option><option>{t("Tempo")}</option><option>{t("Truck")}</option><option>{t("Other")}</option></select></div><div style={{flex:1}}><label htmlFor="dv">{t("Vehicle number")}</label><input id="dv" value={f.v} onChange={set('v')}/></div></div>
    <div className="row" style={{flexWrap:'nowrap'}}><div style={{flex:1}}><label htmlFor="dc">{t("Can carry (kg)")}</label><input id="dc" type="number" min="1" value={f.c} onChange={set('c')}/></div><div style={{flex:1}}><label htmlFor="dl">{t("Licence number")}</label><input id="dl" value={f.l} onChange={set('l')}/></div></div>
    <label>{t("Areas you can cover")}</label><div className="row">{['Deola','Dindori','Trimbakeshwar'].map(x=><span key={x} className="fc" onClick={e=>e.currentTarget.classList.toggle('on')}>{t(x)}</span>)}</div>
    <label>{t("Photos")}</label><div className="g3">{['Licence','Vehicle papers','Vehicle'].map(x=><div key={x} style={{border:'1px dashed var(--brl)',borderRadius:10,padding:'10px 4px',textAlign:'center',fontSize:12,color:'var(--mut)',cursor:'pointer'}} onClick={()=>a.toast(t("Photo upload opens here."))}><i className="ti ti-camera" style={{fontSize:20,display:'block'}}></i>{t(x)}</div>)}</div>
    <div className="err">{t(er)}</div><div className="row"><SendCancel label={t("Send application")} onSend={send}/></div></Shell>;
}

export default function Modals(){
  const {modal:m}=useApp();
  if(!m)return null;
  return m.t==='plant'?<PlantModal key={m.k+(m.vn||'')} k={m.k} vn={m.vn}/>:m.t==='art'?<ArtModal key={m.k} k={m.k}/>:m.t==='all'?<AllModal/>:m.t==='swap'?<SwapModal v={m.v} id={m.id}/>:<DrvModal/>;
}
