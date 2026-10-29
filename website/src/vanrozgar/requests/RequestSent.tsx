import {useEffect} from 'react';
import {useApp} from '../store';
import {Foot,prod,unit} from '../helpers';
import {Timeline,cost,fmtDate,qtyText} from './common';

export default function RequestSent({id}:{id:string}){
  const a=useApp(),r=a.reqs.find(x=>x.id===id);
  useEffect(()=>{if(!r)location.hash='#/my-requests'},[r]);
  if(!r)return null;
  return <div className="rq-page">
    <div style={{textAlign:'center',maxWidth:420,margin:'10px auto'}}><div className="rq-ok"><i className="ti ti-check"></i></div><h1>Request sent</h1><div className="sub">Your request went to the {r.v} Gram Sabha. Request number {r.id}.</div></div>
    <div className="rq-card" style={{maxWidth:420,margin:'0 auto'}}>
      <h2 style={{fontSize:15}}>{prod(r.p).pr}</h2>
      <div className="kv"><span>Quantity</span><span>{qtyText(r)}</span></div>
      <div className="kv"><span>Estimated cost</span><span>{cost(r.p,r.qty)}</span></div>
      <div className="kv"><span>Needed by</span><span>{fmtDate(r.need)}</span></div>
      <h2 style={{fontSize:15,marginTop:14}}>What happens next</h2>
      <div className="rq-tl"><div className="done"><i></i><p><b>Your request is sent</b></p></div><div className="cur"><i></i><p><b>The Gram Sabha reviews it</b></p></div><div><i></i><p><b>You get an answer</b><span>Accepted, a counter offer, or rejected. You will see it in My requests.</span></p></div></div>
      <button type="button" className="b1 rq-full" onClick={()=>{location.hash='#/my-requests'}}>View my requests</button>
      <div style={{textAlign:'center',marginTop:10}}><a className="rq-lk" href="#/resources">Back to resources</a></div>
    </div>
    <Foot/>
  </div>;
}
export {Timeline};
