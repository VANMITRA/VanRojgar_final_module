import {useState} from 'react';
import {useApp} from '../store';
import Shell from './Shell';
import {AGREE_MSG,Chips,Chk,Done,Errs,Head,PhoneBlock,Submit,Txt,contactErrs,pinOk,req,toHome,useForm} from './fields';
import {useT} from '../i18n';

export default function BuyerForm(){const t=useT();
  const a=useApp();const [done,setDone]=useState(false);
  const f=useForm({name:'',phone:'',verified:false,email:'',city:'',district:'',state:'',pin:'',address:'',as:'Person',biz:'',terms:false});
  const go=()=>{
    const v=f.v,e:Errs={};
    contactErrs(v,e);
    req(e,'city',v.city);req(e,'district',v.district);req(e,'state',v.state);
    if(!pinOk(v.pin))e.pin='Enter a 6-digit PIN code.';
    if(v.as==='Business')req(e,'biz',v.biz);
    if(!v.terms)e.terms=AGREE_MSG;
    f.submit('buyer',e,()=>{a.setRole('buy');setDone(true)});
  };
  if(done)return <Done title={t("Your account is ready")} text={t("You can browse and send requests now.")}><button type="button" className="btn" onClick={toHome}>{t("Go to Home")}</button></Done>;
  return <Shell>
    <Head title={t("General buyer")} sub={t("Create your account in a minute.")} back="#/signup"/>
    <div className="f2">
      <Txt f={f} id="name" label={t("Full name")} span/>
      <PhoneBlock f={f}/>
      <Txt f={f} id="email" label={t("Email")} type="email" span/>
      <Txt f={f} id="city" label={t("City or village")} span/>
      <Txt f={f} id="district" label={t("District")}/><Txt f={f} id="state" label={t("State")}/><Txt f={f} id="pin" label={t("PIN code")} im max={6}/>
      <Txt f={f} id="address" label={t("Address")} opt span ph={t("You can add this when you order")}/>
    </div>
    <label>{t("I am buying as")}</label>
    <Chips id="as" options={['Person','Business']} value={f.v.as} onPick={f.set('as')}/>
    {f.v.as==='Business'&&<div className="f2"><Txt f={f} id="biz" label={t("Business name")} span/></div>}
    <Chk f={f} id="terms"/>
    <Submit busy={f.busy} label={t("Create account")} onClick={go}/>
  </Shell>;
}
