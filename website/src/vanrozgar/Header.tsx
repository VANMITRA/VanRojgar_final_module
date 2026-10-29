import {useApp} from './store';
import Logo from './Logo';
import {NAV} from './helpers';
import LangSelect from './LangSelect';

export default function Header(){
  const a=useApp();
  return <header><div className="wrap"><div className="top"><div className="logo" onClick={()=>{location.hash='#/'}}><Logo/></div>
    <div className="search"><i className="ti ti-search"></i><input placeholder={a.t('Search bamboo, Moh, awla...')} onKeyDown={e=>{if(e.key==='Enter')a.toast('Search will work here once the backend is ready.')}}/></div>
    <LangSelect/>
    <button className="ib" aria-label="Switch theme" onClick={a.toggleTheme}><i className={`ti ti-${a.theme==='dark'?'sun':'moon'}`}></i></button>
    <button className="ib cartb" aria-label={`Cart, ${a.cart.reduce((s,x)=>s+x.n,0)} items`} onClick={()=>{location.hash='#/cart'}}><i className="ti ti-shopping-cart"></i>{a.cart.length>0&&<span className="cn">{a.cart.reduce((s,x)=>s+x.n,0)}</span>}</button>
    {a.role==='out'?<button className="b1" onClick={()=>{location.hash='#/login'}}>{a.t('Login')}</button>
    :<button className={`ib pfb${a.cur==='profile'?' on':''}`} aria-label={a.t('My profile')} title={a.t('My profile')} onClick={()=>{location.hash='#/profile'}}><i className="ti ti-user"></i></button>}
    </div>
    <nav>{NAV.map(n=><a key={n[0]} className={a.cur===n[0]?'on':''} href={`#/${n[0]}`}>{a.t(n[1])}</a>)}</nav></div></header>;
}
