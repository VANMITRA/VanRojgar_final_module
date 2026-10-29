import {useEffect,useRef} from 'react';
import {useApp} from './store';
import Logo from './Logo';
import {NAV} from './helpers';
import {LangSwitch,useT} from './i18n';

export default function Header(){
  const a=useApp(),t=useT(),ref=useRef<HTMLElement>(null);
  const n=a.cart.reduce((s,x)=>s+x.n,0);
  /* The header is fixed, so tell the page how tall it is */
  useEffect(()=>{
    const el=ref.current;if(!el)return;
    const set=()=>{const h=el.offsetHeight;(document.querySelector('.vr') as HTMLElement|null)?.style.setProperty('--hh',h+'px');document.documentElement.style.scrollPaddingTop=h+8+'px'};
    set();const ro=new ResizeObserver(set);ro.observe(el);
    return()=>{ro.disconnect();document.documentElement.style.scrollPaddingTop=''};
  },[]);
  return <header ref={ref}><div className="wrap"><div className="top"><div className="logo" onClick={()=>{location.hash='#/'}}><Logo/></div>
    <div className="search"><i className="ti ti-search"></i><input aria-label={t('Search')} placeholder={t('Search bamboo, Moh, awla...')} onKeyDown={e=>{if(e.key==='Enter')a.toast(t('Search will work here once the backend is ready.'))}}/></div>
    <button className="ib" aria-label={t('Switch theme')} onClick={a.toggleTheme}><i className={`ti ti-${a.theme==='dark'?'sun':'moon'}`}></i></button>
    <LangSwitch/>
    <button className="ib cartb" aria-label={t('Cart')} onClick={()=>{location.hash='#/cart'}}><i className="ti ti-shopping-cart"></i>{n>0&&<span className="cn">{n}</span>}</button>
    <div style={{position:'relative'}}>
      {a.role==='out'?<button className="b1" onClick={()=>{location.hash='#/login'}}>{t('Login')}</button>
      :<div className="acc"><a className="b2" href="#/account" onClick={()=>a.setMenu(false)}><i className="ti ti-user"></i><span className="acc-t">{t('Account')}</span></a>
        <button className="b2 acc-c" aria-label={t('More')} aria-expanded={a.menu} onClick={()=>a.setMenu(!a.menu)}><i className="ti ti-chevron-down"></i></button></div>}
      {a.role!=='out'&&a.menu&&<div className="menu"><div onClick={()=>{a.setRole('out');a.setMenu(false);location.hash='#/'}}><i className="ti ti-logout"></i> {t('Log out')}</div></div>}
    </div></div>
    <nav>{NAV.map(x=><a key={x[0]} className={a.cur===x[0]?'on':''} href={`#/${x[0]}`}>{t(x[1])}</a>)}</nav></div></header>;
}
