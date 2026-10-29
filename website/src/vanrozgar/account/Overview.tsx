import {useApp} from '../store';
import {Pic,RN,prod} from '../helpers';
import {useT} from '../i18n';
import {StatusChip,fmtDate,qtyText} from '../requests/common';
import {STATUS_LABEL,Status} from '../requests/mock';

const COUNTS:Status[]=['pending','countered','accepted','rejected'];

export default function Overview(){
  const a=useApp(),t=useT();
  const latest=a.reqs.slice(0,3);
  return <>
    <div className="st acct-me" style={{marginBottom:16}}>
      <h1 style={{fontSize:22,margin:0}}>{a.profile.name||t('Welcome')}</h1>
      <div className="row" style={{gap:14,marginTop:6}}><span className="chip">{t(RN[a.role]||RN.buy)}</span><span className="lc"><i className="ti ti-phone"></i> +91 {a.phone||'—'}</span></div>
      {!a.profile.name&&<div className="lc" style={{marginTop:8}}>{t('Add your name in Profile and settings.')}</div>}
    </div>
    <div className="fg">{COUNTS.map(k=><a key={k} className="st acct-c" href="#/account/requests"><div className="big">{a.reqs.filter(r=>r.st===k).length}</div><div className="lc">{t(STATUS_LABEL[k])}</div></a>)}</div>
    <div className="row" style={{justifyContent:'space-between',margin:'20px 0 8px'}}><h2 style={{fontSize:18}}>{t('Latest requests')}</h2><a className="rq-lk" href="#/account/requests">{t('View all')}</a></div>
    {latest.length?latest.map(r=>{const p=prod(r.p);return <a key={r.id} className="rq-it" href={'#/account/requests/'+r.id}>
      <div className="rq-th"><Pic k={p.i} kind={p.k} col={p.c}/></div>
      <div style={{flex:1,minWidth:0}}><b style={{fontWeight:500,color:'var(--h)'}}>{t(p.pr)}</b><div style={{fontSize:12.5,color:'var(--mut)'}}>{t('{village} Gram Sabha · {qty} · {date}',{village:r.v,qty:qtyText(r,t),date:fmtDate(r.d)})}</div></div>
      <StatusChip s={r.st}/><i className="ti ti-chevron-right" style={{color:'var(--mut)'}}></i></a>}):<div className="st" style={{textAlign:'center',color:'var(--mut)'}}>{t('No requests yet.')}</div>}
  </>;
}
