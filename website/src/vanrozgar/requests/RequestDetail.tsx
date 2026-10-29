import {useEffect} from 'react';
import {useApp} from '../store';
import {Foot,prod,unit} from '../helpers';
import {Crumb,StatusChip,Timeline,costText,fmtDate,qtyText,useNeedLogin} from './common';
import {Req,Status} from './mock';
import {useT} from '../i18n';

export default function RequestDetail({id}:{id:string}){const t=useT();
  const a=useApp();const out=useNeedLogin();
  const r=a.reqs.find(x=>x.id===id);
  useEffect(()=>{if(!r&&!out)location.hash='#/account/requests'},[r,out]);
  if(!r||out)return null;
  const p=prod(r.p);
  const upd=(f:(x:Req)=>Req)=>a.setReqs(prev=>prev.map(x=>x.id===id?f(x):x));
  /* TODO: send these answers to the server */
  const accept=()=>upd(x=>({...x,st:'accepted',qty:x.co!.qty,msg:'You accepted the counter offer. The Gram Sabha will contact you.'}));
  const cancel=()=>upd(x=>({...x,st:'cancelled'}));

  return <div className="rq-page">
    <Crumb><a className="rq-lk" href="#/account/requests">{t("My requests")}</a> › {r.id}</Crumb>
    <div className="row" style={{justifyContent:'space-between',alignItems:'flex-start'}}><div><h1>{t(p.pr)}</h1><div className="sub">{t("To the {village} Gram Sabha · Request {id}",{village:r.v,id:r.id})}</div></div><StatusChip s={r.st}/></div>
    <div className="rq-g">
      <div className="rq-card"><h2 style={{fontSize:15}}>{t("Progress")}</h2><Timeline r={r}/>
        {r.st==='countered'&&r.co&&<div className="rq-box counter"><b>{t("The Gram Sabha made you an offer")}</b>{t("{qty} for about {cost}.",{qty:qtyText({p:r.p,qty:r.co.qty},t),cost:costText(r.p,r.co.qty,t)})}<div style={{marginTop:4}}>{t(r.co.msg)}</div>
          <div className="row" style={{marginTop:10}}><button type="button" className="b1" onClick={accept}>{t("Accept offer")}</button><button type="button" className="b2" onClick={cancel}>{t("Decline offer")}</button></div></div>}
        {r.st==='accepted'&&r.msg&&<div className="rq-box good"><b>{t("Message from the Gram Sabha")}</b>{t(r.msg||"")}</div>}
        {r.st==='rejected'&&<><div className="rq-box bad"><b>{t("Reason from the Gram Sabha")}</b>{t(r.msg||"")}</div><div style={{marginTop:10}}><a className="rq-lk" href="#/resources">{t("Search {name} in other Gram Sabhas",{name:t(p.n)})}</a></div></>}
        {r.st==='pending'&&<><div style={{marginTop:12}}><button type="button" className="b2" onClick={cancel}>{t("Cancel request")}</button></div></>}
      </div>
      <div className="rq-card" style={{alignSelf:'start'}}><h2 style={{fontSize:15}}>{t("Your request")}</h2>
        <div className="kv"><span>{t("Quantity")}</span><span>{qtyText(r,t)}</span></div>
        <div className="kv"><span>{t("Estimated cost")}</span><span>{costText(r.p,r.qty,t)}</span></div>
        <div className="kv"><span>{t("Why")}</span><span>{t(r.why)}</span></div>
        <div className="kv"><span>{t("Needed by")}</span><span>{fmtDate(r.need)}</span></div>
        <div className="kv"><span>{t("Get it by")}</span><span>{r.how==='Pick up'?t("Pick-up"):t("Delivery")}</span></div>
      </div>
    </div>
    <Foot/>
  </div>;
}
