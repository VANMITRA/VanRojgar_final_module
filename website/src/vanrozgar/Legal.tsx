import {Fragment,ReactNode} from 'react';
import {PACKS,useLang,useT} from './i18n';
import {CONTACT} from './siteConfig';

const bold=(s:string):ReactNode[]=>s.split(/\*\*(.+?)\*\*/).map((x,i)=>i%2?<b key={i}>{x}</b>:<Fragment key={i}>{x}</Fragment>);

export function ImpactTabs({cur}:{cur:string}){
  const t=useT();
  return <div className="tabs" role="tablist">{[['','Our impact'],['terms','Terms and conditions'],['privacy','Privacy policy']].map(x=>
    <a key={x[0]} role="tab" aria-selected={cur===x[0]} className={cur===x[0]?'on':''} href={x[0]?`#/impact/${x[0]}`:'#/impact'}>{t(x[1])}</a>)}</div>;
}

export default function Legal({kind}:{kind:'terms'|'privacy'}){
  const {lang}=useLang(),t=useT();
  const L=PACKS[lang].legal||PACKS.en.legal,d=L[kind];
  const go=(i:number)=>document.getElementById(`${kind}-${i+1}`)?.scrollIntoView({behavior:'smooth',block:'start'});
  const hasContact=!!(CONTACT.email||CONTACT.phone);
  return <article className="legal">
    <h1>{d.title}</h1>
    <div className="sub">{L.updatedLabel}</div>
    <nav className="toc" aria-label={L.contents}><b>{L.contents}</b><ol>{d.sections.map((s:any,i:number)=><li key={i}><button type="button" className="lnk" onClick={()=>go(i)}>{s.h}</button></li>)}</ol></nav>
    {d.sections.map((s:any,i:number)=><section key={i} id={`${kind}-${i+1}`}>
      <h2>{i+1}. {s.h}</h2>
      {s.body.map((b:any,j:number)=>Array.isArray(b)?<ul key={j}>{b.map((x:string,k:number)=><li key={k}>{bold(x)}</li>)}</ul>:<p key={j}>{bold(b)}</p>)}
    </section>)}
    {hasContact&&<p className="contact">{t('Contact us')}: {[CONTACT.email,CONTACT.phone].filter(Boolean).join(' · ')}</p>}
  </article>;
}
