import {useState} from 'react';
import {useApp} from '../store';
import {Foot,Pic,prod} from '../helpers';
import {Crumb,StatusChip,qtyText,useNeedLogin} from './common';
import {STATUS_LABEL,Status} from './mock';

const KEYS:(Status|'All')[]=['All','pending','countered','accepted','rejected','cancelled'];

export default function MyRequests(){
  const a=useApp();const out=useNeedLogin();const [fl,setFl]=useState<Status|'All'>('All');
  if(out)return null;
  const cnt=(k:string)=>k==='All'?a.reqs.length:a.reqs.filter(x=>x.st===k).length;
  const rs=a.reqs.filter(x=>fl==='All'||x.st===fl);
  return <div className="rq-page">
    <Crumb>Account › My requests</Crumb>
    <h1>My requests</h1><div className="sub">Every request you sent to a Gram Sabha, and its answer.</div>
    <div className="row" style={{marginBottom:12}}>{KEYS.map(k=><button key={k} type="button" className={`fc${fl===k?' on':''}`} aria-pressed={fl===k} onClick={()=>setFl(k)}>{k==='All'?'All':STATUS_LABEL[k]} ({cnt(k)})</button>)}</div>
    {rs.length?rs.map(r=>{const p=prod(r.p);return <a key={r.id} className="rq-it" href={'#/my-requests/'+r.id}>
      <div className="rq-th"><Pic k={p.i} kind={p.k} col={p.c}/></div>
      <div style={{flex:1,minWidth:0}}><b style={{fontWeight:500,color:'var(--h)'}}>{p.pr}</b><div style={{fontSize:12.5,color:'var(--mut)'}}>{r.v} Gram Sabha · {qtyText(r)} · {r.d}</div></div>
      <StatusChip s={r.st}/><i className="ti ti-chevron-right" style={{color:'var(--mut)'}}></i></a>}):<div className="rq-card" style={{textAlign:'center',color:'var(--mut)'}}>No requests here yet.</div>}
    <Foot/>
  </div>;
}
