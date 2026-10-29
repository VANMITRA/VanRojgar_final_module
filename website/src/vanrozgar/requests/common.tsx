import {ReactNode,useEffect} from 'react';
import {useApp} from '../store';
import {byId,nf,unit} from '../helpers';
import {Req,Status,STATUS_LABEL} from './mock';
import './requests.css';

/* The shown price is for `per` units, for example 5 poles */
export const per=(id:string)=>parseInt(byId[id]?.u)||1;
export const cost=(id:string,q:number)=>byId[id]?<>&#8377;{nf(Math.round(byId[id].p*q/per(id)))}</>:<>Price on request</>;
export const fmtDate=(s:string)=>/^\d{4}-/.test(s)?new Date(s+'T00:00:00').toLocaleDateString('en-GB',{day:'numeric',month:'short',year:'numeric'}):s;
export const today=()=>new Date().toISOString().slice(0,10);
export const StatusChip=({s}:{s:Status})=><span className={`rq-st ${s}`}>{STATUS_LABEL[s]}</span>;
export const Crumb=({children}:{children:ReactNode})=><div className="rq-crumb">{children}</div>;

/* Requests need an account */
export function useNeedLogin(){
  const a=useApp();
  useEffect(()=>{if(a.role==='out'){a.toast('Log in to send and follow requests.');location.hash='#/login'}},[a.role]);
  return a.role==='out';
}

function Step({c,t,x}:{c:string,t:string,x?:string}){return <div className={c}><i></i><p><b>{t}</b>{x&&<span>{x}</span>}</p></div>}
export function Timeline({r}:{r:Req}){
  const s=r.st;
  const a=<Step c="done" t="Request sent" x={r.d}/>,b=<Step c={s==='pending'?'cur':'done'} t="Gram Sabha reviews it"/>;
  return <div className="rq-tl">{
    s==='pending'?<>{a}{b}<Step c="" t="Answer"/></>
    :s==='accepted'?<>{a}{b}<Step c="done" t="Accepted"/><Step c="cur" t="Pick-up or delivery" x={r.how==='Pick up'?'The Gram Sabha will call you to fix a pick-up time.':'A delivery partner will be assigned.'}/></>
    :s==='countered'?<>{a}{b}<Step c="cur" t="Counter offer" x="Waiting for your answer"/></>
    :s==='rejected'?<>{a}{b}<Step c="bad" t="Rejected"/></>
    :<>{a}<Step c="bad" t="Cancelled"/></>}</div>;
}
export const qtyText=(r:{p:string,qty:number})=>`${nf(r.qty)} ${unit(r.p)}`;
