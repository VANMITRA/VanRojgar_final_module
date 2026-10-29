import {useEffect} from 'react';
import {useApp} from '../store';
import {Foot,prod,unit} from '../helpers';
import {Timeline,costText,fmtDate,qtyText} from './common';
import {useT} from '../i18n';

export default function RequestSent({id}:{id:string}){const t=useT();
  const a=useApp(),r=a.reqs.find(x=>x.id===id);
  useEffect(()=>{if(!r)location.hash='#/account/requests'},[r]);
  if(!r)return null;
  return <div className="rq-page">
    <div style={{textAlign:'center',maxWidth:420,margin:'10px auto'}}><div className="rq-ok"><i className="ti ti-check"></i></div><h1>{t("Request sent")}</h1><div className="sub">{t("Your request went to the {village} Gram Sabha. Request number {id}.",{village:r.v,id:r.id})}</div></div>
    <div className="rq-card" style={{maxWidth:420,margin:'0 auto'}}>
      <h2 style={{fontSize:15}}>{t(prod(r.p).pr)}</h2>
      <div className="kv"><span>{t("Quantity")}</span><span>{qtyText(r,t)}</span></div>
      <div className="kv"><span>{t("Estimated cost")}</span><span>{costText(r.p,r.qty,t)}</span></div>
      <div className="kv"><span>{t("Needed by")}</span><span>{fmtDate(r.need)}</span></div>
      <h2 style={{fontSize:15,marginTop:14}}>{t("What happens next")}</h2>
      <div className="rq-tl"><div className="done"><i></i><p><b>{t("Your request is sent")}</b></p></div><div className="cur"><i></i><p><b>{t("The Gram Sabha reviews it")}</b></p></div><div><i></i><p><b>{t("You get an answer")}</b><span>{t("Accepted, a counter offer, or rejected. You will see it in My requests.")}</span></p></div></div>
      <button type="button" className="b1 rq-full" onClick={()=>{location.hash='#/account/requests'}}>{t("View my requests")}</button>
      <div style={{textAlign:'center',marginTop:10}}><a className="rq-lk" href="#/resources">{t("Back to resources")}</a></div>
    </div>
    <Foot/>
  </div>;
}
export {Timeline};
