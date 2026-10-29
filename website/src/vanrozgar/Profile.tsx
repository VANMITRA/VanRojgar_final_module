import {ReactNode,useState} from 'react';
import {useApp} from './store';
import {Foot,RN,prod} from './helpers';
import {StatusChip,useNeedLogin} from './requests/common';
import {LANGS} from './lang';
import {phoneOk,emailOk,PHONE_MSG} from './auth/fields';
import './profile.css';

const ABOUT:Record<string,string>={
  gs:'Manage the village stock and approve requests',
  vil:'Sell your own forest produce',
  buy:'Buy forest produce from villages',
  drv:'Carry forest goods from villages to buyers and earn on every trip.',
};
const ACT:Record<string,[string,string]>={
  gs:['Register a Gram Sabha','#/signup/gram-sabha'],
  vil:['Sell with VanMitra','#/signup/villager/sell'],
  buy:['Shop resources','#/resources'],
  drv:['Deliver with us','#/deliver'],
};

const Row=({k,children}:{k:string,children:ReactNode})=><div className="pf-row"><span>{k}</span><b>{children}</b></div>;

export default function Profile(){
  const a=useApp(),out=useNeedLogin();
  const [edit,setEdit]=useState(false),[d,setD]=useState({name:'',phone:'',email:'',place:''}),[er,setEr]=useState<Record<string,string>>({});
  if(out)return null;
  const start=()=>{setD({name:a.user.name||'',phone:a.user.phone||'',email:a.user.email||'',place:a.user.place||''});setEr({});setEdit(true)};
  const set=(k:string)=>(e:React.ChangeEvent<HTMLInputElement>)=>setD({...d,[k]:k==='phone'?e.target.value.replace(/\D/g,'').slice(0,10):e.target.value});
  /* TODO: save to the server. A changed phone number should be checked with a new OTP. */
  const save=()=>{
    const x:Record<string,string>={};
    if(!d.name.trim())x.name='This field is required.';
    if(!phoneOk(d.phone))x.phone=PHONE_MSG;
    if(d.email.trim()&&!emailOk(d.email))x.email='Enter a valid email.';
    setEr(x);if(Object.keys(x).length)return;
    a.setUser({name:d.name.trim(),phone:d.phone,email:d.email.trim(),place:d.place.trim()});setEdit(false);a.toast('Profile updated.');
  };
  const In=(k:string,label:string,type='text',ph?:string)=><div key={k} className="pf-ed"><label htmlFor={'pf-'+k}>{label}</label><input id={'pf-'+k} type={type} placeholder={ph} value={(d as any)[k]} onChange={set(k)} aria-invalid={!!er[k]}/>{er[k]&&<div className="e" role="alert">{er[k]}</div>}</div>;
  const pending=a.reqs.filter(r=>r.st==='pending'||r.st==='countered').length;
  const name=a.user.name||'VanMitra member',act=ACT[a.role]||ACT.buy;
  return <div className="pf">
    <div className="pf-top"><h1>My profile</h1>
      <div className="row" style={{gap:8}}>{!edit&&<button type="button" className="pf-out" onClick={start}><i className="ti ti-pencil"></i> Edit</button>}<button type="button" className="pf-out" onClick={()=>{a.setRole('out');a.setUser({});location.hash='#/'}}><i className="ti ti-logout"></i> Log out</button></div></div>
    <div className="pf-grid">
      <div className="pf-card pf-me">
        <div className="pf-av"><i className="ti ti-user"></i></div>
        <h2>{name}</h2>
        {a.user.phone&&<div className="pf-ph">+91 {a.user.phone}</div>}
        <span className="chip">{RN[a.role]}</span>
        <p>{ABOUT[a.role]}</p>
        <a className="b2 pf-act" href={act[1]}>{act[0]}</a>
      </div>
      <div className="pf-card">
        <h3>Account details</h3>
        <Row k="Role">{RN[a.role]}</Row>
        {edit?<>
          {In('name','Full name')}{In('phone','Phone number','tel','10-digit number')}
          {In('email','Email','email')}{In('place','City or village')}
          <div className="pf-btns"><button type="button" className="b1" onClick={save}>Save changes</button><button type="button" className="b2" onClick={()=>setEdit(false)}>Cancel</button></div>
        </>:<>
          <Row k="Name">{a.user.name||'Not added yet'}</Row>
          <Row k="Phone">{a.user.phone?'+91 '+a.user.phone:'Not added yet'}</Row>
          <Row k="Email">{a.user.email||'Not added yet'}</Row>
          <Row k="City or village">{a.user.place||'Not added yet'}</Row>
        </>}
        <Row k="Language"><select aria-label="Language" value={a.lang} onChange={e=>a.setLang(e.target.value as any)}>{LANGS.map(l=><option key={l.id} value={l.id}>{l.label}</option>)}</select></Row>
        <Row k="Theme"><button type="button" className="pf-link" onClick={a.toggleTheme}>{a.theme==='dark'?'Switch to light':'Switch to dark'}</button></Row>
      </div>
      <div className="pf-card">
        <h3>Quick access</h3>
        <a className="pf-tile" href="#/wishlist"><i className="ti ti-heart"></i><span>Wishlist</span><b>{a.wish.length}</b></a>
        <a className="pf-tile" href="#/my-requests"><i className="ti ti-package"></i><span>My requests</span><b>{a.reqs.length}</b></a>
        <a className="pf-tile" href="#/cart"><i className="ti ti-shopping-cart"></i><span>Cart</span><b>{a.cart.reduce((s,x)=>s+x.n,0)}</b></a>
      </div>
      <div className="pf-card pf-wide">
        <div className="pf-head"><h3>Recent requests</h3>{pending>0&&<span className="lc">{pending} waiting for an answer</span>}<a href="#/my-requests">View all</a></div>
        {a.reqs.length?a.reqs.slice(0,3).map(r=><a key={r.id} className="pf-req" href={'#/my-requests/'+r.id}>
          <div><small>{r.id}</small><b>{prod(r.p).n}</b></div><div><small>Gram Sabha</small><b>{r.v}</b></div><div><small>Date</small><b>{r.d}</b></div><StatusChip s={r.st}/>
        </a>):<div className="lc">No requests here yet.</div>}
      </div>
    </div>
    <Foot/>
  </div>;
}
