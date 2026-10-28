import {useApp} from './store';
import Logo from './Logo';
import {NAV,RN} from './helpers';

export default function Header(){
  const a=useApp();
  return <header><div className="wrap"><div className="top"><div className="logo" onClick={()=>{location.hash='#/'}}><Logo/></div>
    <div className="search"><i className="ti ti-search"></i><input placeholder="Search bamboo, Moh, awla..." onKeyDown={e=>{if(e.key==='Enter')a.toast('Search will work here once the backend is ready.')}}/></div>
    <button className="ib" aria-label="Switch theme" onClick={a.toggleTheme}><i className={`ti ti-${a.theme==='dark'?'sun':'moon'}`}></i></button>
    <button className="ib cartb" aria-label={`Cart, ${a.cart.reduce((s,x)=>s+x.n,0)} items`} onClick={()=>{location.hash='#/cart'}}><i className="ti ti-shopping-cart"></i>{a.cart.length>0&&<span className="cn">{a.cart.reduce((s,x)=>s+x.n,0)}</span>}</button>
    <div style={{position:'relative'}}>
      {a.role==='out'?<button className="b1" onClick={()=>{location.hash='#/login'}}>Login</button>
      :<button className="b2" onClick={()=>a.setMenu(!a.menu)}><i className="ti ti-user"></i> Account <i className="ti ti-chevron-down"></i></button>}
      {a.role!=='out'&&a.menu&&<div className="menu"><div style={{color:'var(--mut)',cursor:'default',fontSize:12}}>{RN[a.role]}</div>
        <div onClick={()=>a.toast('My profile opens here.')}><i className="ti ti-user"></i> My profile</div>
        <div onClick={()=>{a.setMenu(false);location.hash='#/wishlist'}}><i className="ti ti-heart"></i> Wishlist</div>
        <div onClick={()=>{a.setMenu(false);location.hash='#/my-requests'}}><i className="ti ti-package"></i> My requests</div>
        <div style={{borderTop:'1px solid var(--bd)'}} onClick={()=>{a.setRole('out');a.setMenu(false)}}><i className="ti ti-logout"></i> Log out</div></div>}
    </div></div>
    <nav>{NAV.map(n=><a key={n[0]} className={a.cur===n[0]?'on':''} href={`#/${n[0]}`}>{n[1]}</a>)}</nav></div></header>;
}
