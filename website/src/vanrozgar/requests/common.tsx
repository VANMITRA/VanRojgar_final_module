import {ReactNode,useEffect} from 'react';
import {useApp} from '../store';
import {byId,dateText,nf,unit} from '../helpers';
import {Req,Status,STATUS_LABEL} from './mock';
import './requests.css';
import {useT} from '../i18n';

/* The shown price is for `per` units, for example 5 poles */
export const per=(id:string)=>parseInt(byId[id]?.u)||1;
export const costText=(id:string,q:number,t:(x:string)=>string)=>byId[id]?'₹'+nf(Math.round(byId[id].p*q/per(id))):t('Price on request');
export const fmtDate=dateText;
export const today=()=>new Date().toISOString().slice(0,10);
export const StatusChip=({s}:{s:Status})=>{const t=useT();return <span className={`rq-st ${s}`}>{t(STATUS_LABEL[s])}</span>};
export const Crumb=({children}:{children:ReactNode})=><div className="rq-crumb">{children}</div>;

/* Requests need an account */
export function useNeedLogin(){const t=useT();
  const a=useApp();
  useEffect(()=>{if(a.role==='out'){a.toast(t("Log in to send and follow requests."));location.hash='#/login'}},[a.role]);
  return a.role==='out';
}

function Step({c,t,x}:{c:string,t:string,x?:string}){return <div className={c}><i></i><p><b>{t}</b>{x&&<span>{x}</span>}</p></div>}
export function Timeline({r}:{r:Req}){const t=useT();
  const s=r.st;
  const a=<Step c="done" t={t("Request sent")} x={fmtDate(r.d)}/>,b=<Step c={s==='pending'?'cur':'done'} t={t("Gram Sabha reviews it")}/>;
  return <div className="rq-tl">{
    s==='pending'?<>{a}{b}<Step c="" t={t("Answer")}/></>
    :s==='accepted'?<>{a}{b}<Step c="done" t={t("Accepted")}/><Step c="cur" t={t("Pick-up or delivery")} x={r.how==='Pick up'?t('The Gram Sabha will call you to fix a pick-up time.'):t('A delivery partner will be assigned.')}/></>
    :s==='countered'?<>{a}{b}<Step c="cur" t={t("Counter offer")} x={t("Waiting for your answer")}/></>
    :s==='rejected'?<>{a}{b}<Step c="bad" t={t("Rejected")}/></>
    :<>{a}<Step c="bad" t={t("Cancelled")}/></>}</div>;
}
export const qtyText=(r:{p:string,qty:number},t?:(x:string)=>string)=>`${nf(r.qty)} ${t?t(unit(r.p)):unit(r.p)}`;
