import {useState} from 'react';
import {useApp} from '../store';
import Shell from './Shell';
import {Chips,Chk,Done,Errs,Head,PhoneBlock,Submit,Txt,contactErrs,pinOk,req,toHome,useForm} from './fields';

export default function BuyerForm(){
  const a=useApp();const [done,setDone]=useState(false);
  const f=useForm({name:'',phone:'',verified:false,email:'',city:'',district:'',state:'',pin:'',address:'',as:'Person',biz:'',terms:false});
  const go=()=>{
    const v=f.v,e:Errs={};
    contactErrs(v,e);
    req(e,'city',v.city);req(e,'district',v.district);req(e,'state',v.state);
    if(!pinOk(v.pin))e.pin='Enter a 6-digit PIN code.';
    if(v.as==='Business')req(e,'biz',v.biz);
    if(!v.terms)e.terms='Please agree to continue.';
    f.submit('buyer',e,()=>{a.setRole('buy');a.setUser({name:f.v.name,phone:f.v.phone});setDone(true)});
  };
  if(done)return <Done title="Your account is ready" text="You can browse and send requests now."><button type="button" className="btn" onClick={toHome}>Go to Home</button></Done>;
  return <Shell>
    <Head title="General buyer" sub="Create your account in a minute." back="#/signup"/>
    <div className="f2">
      <Txt f={f} id="name" label="Full name" span/>
      <PhoneBlock f={f}/>
      <Txt f={f} id="email" label="Email" type="email" span/>
      <Txt f={f} id="city" label="City or village" span/>
      <Txt f={f} id="district" label="District"/><Txt f={f} id="state" label="State"/><Txt f={f} id="pin" label="PIN code" im max={6}/>
      <Txt f={f} id="address" label="Address" opt span ph="You can add this when you order"/>
    </div>
    <label>I am buying as</label>
    <Chips id="as" options={['Person','Business']} value={f.v.as} onPick={f.set('as')}/>
    {f.v.as==='Business'&&<div className="f2"><Txt f={f} id="biz" label="Business name" span/></div>}
    <Chk f={f} id="terms"/>
    <Submit busy={f.busy} label="Create account" onClick={go}/>
  </Shell>;
}
