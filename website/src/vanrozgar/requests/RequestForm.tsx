import {useEffect,useState} from 'react';
import {useApp} from '../store';
import {Pic,Foot,byId,loc,unit} from '../helpers';
import {Crumb,cost,today,useNeedLogin} from './common';
import {Req} from './mock';

const WHY=['Resale in my shop','My own use','Processing or making products','Craft or construction','Other'];

export default function RequestForm({pid,village}:{pid:string,village:string}){
  const a=useApp();const out=useNeedLogin();
  const p=byId[pid],row=p?.v.find((r:any)=>r[0]===village);
  const [f,setF]=useState({qty:'',why:'',note:'',need:'',how:'Pick up',addr:'',pin:''}),[errs,setErrs]=useState<Record<string,string>>({});
  useEffect(()=>{if(!p||!row)location.hash='#/resources'},[p,row]);
  if(!p||!row||out)return null;
  const set=(k:string)=>(x:string)=>{setF(o=>({...o,[k]:x}));setErrs(o=>{if(!o[k])return o;const n={...o};delete n[k];return n})};
  const u=unit(pid),dl=f.how==='Deliver to me';

  const send=()=>{
    const e:Record<string,string>={},q=+f.qty;
    if(!(q>0&&Number.isInteger(q)))e.qty='Enter a whole number greater than zero.';
    if(!f.why)e.why='Choose why you need it.';
    if(f.why==='Other'&&f.note.trim().length<10)e.note='Tell the Gram Sabha more (at least 10 letters).';
    if(!f.need||f.need<today())e.need='Choose a date from today.';
    if(dl){if(!f.addr.trim())e.addr='Enter your delivery address.';if(!/^[0-9]{6}$/.test(f.pin))e.pin='Enter a 6-digit PIN code.'}
    const ids=Object.keys(e);
    if(ids.length){setErrs(e);setTimeout(()=>document.getElementById('f-'+ids[0])?.focus(),0);return}
    /* TODO: send the request to the server */
    let id='';
    a.setReqs(prev=>{
      id='VR-'+String(Math.max(0,...prev.map(r=>+r.id.slice(3)))+1).padStart(4,'0');
      const r:Req={id,p:pid,v:village,qty:q,st:'pending',d:new Date().toLocaleDateString('en-GB',{day:'numeric',month:'short',year:'numeric'}),why:f.why,how:f.how,need:f.need};
      return [r,...prev];
    });
    location.hash='#/request/sent/'+id;
  };
  const fld=(k:string,props:any,Tag:'input'|'select'|'textarea'='input',kids?:any)=>{
    const C=Tag as any;
    return <C id={'f-'+k} value={(f as any)[k]} onChange={(ev:any)=>set(k)(ev.target.value)} aria-invalid={!!errs[k]} aria-describedby={errs[k]?'e-'+k:undefined} {...props}>{kids}</C>;
  };
  const err=(k:string)=>errs[k]?<div className="rq-err" id={'e-'+k} role="alert">{errs[k]}</div>:null;

  return <div className="rq-page">
    <Crumb>Home › {p.n} › {village} › Request</Crumb>
    <h1>Request {p.pr.toLowerCase()}</h1>
    <div className="sub">Tell the Gram Sabha what you need. They will accept, counter or reject your request.</div>
    <div className="rq-g">
      <div className="rq-card">
        <div style={{fontSize:12.5,color:'var(--mut)'}}>Sending as <b style={{color:'var(--h)',fontWeight:500}}>your name</b>, +91 98XXXXXX10</div>
        <label htmlFor="f-qty">How much do you need?</label>
        <div className="row" style={{flexWrap:'nowrap'}}>{fld('qty',{type:'number',min:1,placeholder:'Quantity'})}<span style={{whiteSpace:'nowrap'}}>{u}</span></div>
        <div className="rq-hint">Available now (estimate): {row[2]}</div>{err('qty')}
        <label htmlFor="f-why">Why do you need it?</label>
        {fld('why',{},'select',<><option value="">Choose</option>{WHY.map(w=><option key={w}>{w}</option>)}</>)}{err('why')}
        <label htmlFor="f-note">Tell the Gram Sabha more <span className="rq-opt">(required if you chose Other)</span></label>
        {fld('note',{placeholder:'For example: I make baskets and need poles of even thickness.'},'textarea')}{err('note')}
        <label htmlFor="f-need">When do you need it?</label>
        {fld('need',{type:'date',min:today()})}{err('need')}
        <label id="how-l">How do you want to get it?</label>
        <div className="row" role="group" aria-labelledby="how-l">{[['Pick up','I will pick it up'],['Deliver to me','Deliver to me']].map(x=><button key={x[0]} type="button" className={`fc${f.how===x[0]?' on':''}`} aria-pressed={f.how===x[0]} onClick={()=>set('how')(x[0])}>{x[1]}</button>)}</div>
        {dl&&<><label htmlFor="f-addr">Delivery address</label>{fld('addr',{style:{minHeight:56}},'textarea')}{err('addr')}
          <label htmlFor="f-pin">PIN code</label>{fld('pin',{inputMode:'numeric',maxLength:6,style:{maxWidth:160}})}{err('pin')}</>}
        <button type="button" className="b1 rq-full" onClick={send}>Send request</button>
        <div className="rq-hint" style={{textAlign:'center',marginTop:8}}>The Gram Sabha will review your request. You can follow it in My requests.</div>
      </div>
      <div className="rq-card" style={{alignSelf:'start'}}>
        <div className="rq-im"><Pic k={p.i} kind={p.k} col={p.c}/></div>
        <h2 style={{fontSize:15}}>{p.pr}</h2>
        <div className="kv"><span>Gram Sabha</span><span>{village}</span></div>
        <div className="kv"><span>Place</span><span>{loc(village).replace(village+', ','')}</span></div>
        <div className="kv"><span>Price</span><span>&#8377;{p.p} / {p.u}</span></div>
        <div className="kv"><span>Estimated cost</span><span><b>{+f.qty>0?cost(pid,+f.qty):<>&#8377;0</>}</b></span></div>
        <div className="rq-hint">The Gram Sabha confirms the final amount.</div>
      </div>
    </div>
    <Foot/>
  </div>;
}
