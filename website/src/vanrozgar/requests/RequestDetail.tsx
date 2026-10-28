import {useEffect} from 'react';
import {useApp} from '../store';
import {Foot,prod,unit} from '../helpers';
import {Crumb,StatusChip,Timeline,cost,fmtDate,qtyText,useNeedLogin} from './common';
import {Req,Status} from './mock';

export default function RequestDetail({id}:{id:string}){
  const a=useApp();const out=useNeedLogin();
  const r=a.reqs.find(x=>x.id===id);
  useEffect(()=>{if(!r&&!out)location.hash='#/my-requests'},[r,out]);
  if(!r||out)return null;
  const p=prod(r.p);
  const upd=(f:(x:Req)=>Req)=>a.setReqs(prev=>prev.map(x=>x.id===id?f(x):x));
  /* TODO: send these answers to the server */
  const accept=()=>upd(x=>({...x,st:'accepted',qty:x.co!.qty,msg:'You accepted the counter offer. The Gram Sabha will contact you.'}));
  const cancel=()=>upd(x=>({...x,st:'cancelled'}));

  return <div className="rq-page">
    <Crumb><a className="rq-lk" href="#/my-requests">My requests</a> › {r.id}</Crumb>
    <div className="row" style={{justifyContent:'space-between',alignItems:'flex-start'}}><div><h1>{p.pr}</h1><div className="sub">To the {r.v} Gram Sabha · Request {r.id}</div></div><StatusChip s={r.st}/></div>
    <div className="rq-g">
      <div className="rq-card"><h2 style={{fontSize:15}}>Progress</h2><Timeline r={r}/>
        {r.st==='countered'&&r.co&&<div className="rq-box counter"><b>The Gram Sabha made you an offer</b>{r.co.qty} {unit(r.p)} for about {cost(r.p,r.co.qty)}.<div style={{marginTop:4}}>{r.co.msg}</div>
          <div className="row" style={{marginTop:10}}><button type="button" className="b1" onClick={accept}>Accept offer</button><button type="button" className="b2" onClick={cancel}>Decline offer</button></div></div>}
        {r.st==='accepted'&&r.msg&&<div className="rq-box good"><b>Message from the Gram Sabha</b>{r.msg}</div>}
        {r.st==='rejected'&&<><div className="rq-box bad"><b>Reason from the Gram Sabha</b>{r.msg}</div><div style={{marginTop:10}}><a className="rq-lk" href="#/resources">Search {p.n} in other Gram Sabhas</a></div></>}
        {r.st==='pending'&&<><div style={{marginTop:12}}><button type="button" className="b2" onClick={cancel}>Cancel request</button></div></>}
      </div>
      <div className="rq-card" style={{alignSelf:'start'}}><h2 style={{fontSize:15}}>Your request</h2>
        <div className="kv"><span>Quantity</span><span>{qtyText(r)}</span></div>
        <div className="kv"><span>Estimated cost</span><span>{cost(r.p,r.qty)}</span></div>
        <div className="kv"><span>Why</span><span>{r.why}</span></div>
        <div className="kv"><span>Needed by</span><span>{fmtDate(r.need)}</span></div>
        <div className="kv"><span>Get it by</span><span>{r.how==='Pick up'?'Pick-up':'Delivery'}</span></div>
      </div>
    </div>
    <Foot/>
  </div>;
}
