import {useEffect,useRef,useState} from 'react';
import {useApp} from '../store';
import Shell from './Shell';
import {AGREE_MSG,AgreeBox,Done,PHONE_MSG,phoneOk,toHome} from './fields';
import {roleForPhone,sendOtp,verifyOtp} from './auth';
import {useT} from '../i18n';

export default function Login(){const t=useT();
  const a=useApp();
  const [step,setStep]=useState<'phone'|'otp'|'done'>('phone');
  const [phone,setPhone]=useState(''),[err,setErr]=useState(''),[busy,setBusy]=useState(false),[left,setLeft]=useState(0);
  const [agree,setAgree]=useState(false),[ae,setAe]=useState('');
  const [d,setD]=useState(['','','','','','']),box=useRef<(HTMLInputElement|null)[]>([]);
  useEffect(()=>{if(left<=0)return;const t=setTimeout(()=>setLeft(left-1),1000);return()=>clearTimeout(t)},[left]);

  const send=async()=>{
    if(!phoneOk(phone)){setErr(PHONE_MSG);document.getElementById('ph')?.focus();return}
    if(!agree){setAe(AGREE_MSG);document.getElementById('agree')?.focus();return}
    setBusy(true);await sendOtp(phone);setBusy(false);
    setErr('');setD(['','','','','','']);setLeft(30);setStep('otp');setTimeout(()=>box.current[0]?.focus(),0);
  };
  const verify=async()=>{
    const c=d.join('');
    if(c.length<6){setErr('Enter all 6 digits.');box.current[d.findIndex(x=>!x)]?.focus();return}
    setBusy(true);const ok=await verifyOtp(phone,c);
    if(!ok){setBusy(false);setErr('That code is not right. Check the SMS and try again.');box.current[0]?.focus();return}
    a.setPhone(phone);a.setRole(await roleForPhone(phone));a.setMenu(false);setBusy(false);setStep('done');
  };
  const digit=(i:number,x:string)=>{
    const v=x.replace(/\D/g,'').slice(-1);setErr('');setD(p=>p.map((q,j)=>j===i?v:q));
    if(v&&i<5)box.current[i+1]?.focus();
  };
  const paste=(e:React.ClipboardEvent)=>{
    const t=e.clipboardData.getData('text').replace(/\D/g,'').slice(0,6);if(!t)return;
    e.preventDefault();setD([0,1,2,3,4,5].map(i=>t[i]||''));
  };

  if(step==='done')return <Done title={t("Welcome to VanRozgar")} text={t("You are logged in.")}><button type="button" className="btn" onClick={toHome}>{t("Go to Home")}</button></Done>;
  return <Shell login>
    {step==='phone'?<>
      <h3>{t("Login")}</h3>
      <label htmlFor="ph">{t("Phone number")}</label>
      <div className="pill"><span className="pre">+91</span><input id="ph" type="tel" inputMode="numeric" maxLength={10} placeholder={t("Enter your phone number")} value={phone} aria-invalid={!!err} aria-describedby={err?'ph-e':undefined} onChange={e=>{setPhone(e.target.value.replace(/\D/g,''));setErr('')}} onKeyDown={e=>{if(e.key==='Enter')send()}}/></div>
      <div className="hint">{t("We will send a 6-digit code by SMS.")}</div>
      {err&&<div className="e" id="ph-e" role="alert">{t(err)}</div>}
      <AgreeBox id="agree" checked={agree} onChange={b=>{setAgree(b);setAe('')}} err={ae}/>
      <button type="button" className="btn" disabled={busy} onClick={send}>{busy?t("Sending..."):t("Send OTP")}</button>
      <div className="center">{t("Do not have an account?")}<br/><a className="lk" href="#/signup">{t("Sign up")}</a></div></>
    :<>
      <h3>{t("Enter the code")}</h3>
      <div className="sub">{t("Sent to +91")} {phone} <button type="button" className="lk" onClick={()=>{setStep('phone');setErr('')}}>{t("Change number")}</button></div>
      <label htmlFor="otp0">{t("6-digit code")}</label>
      <div className="otp" onPaste={paste}>{d.map((x,i)=><input key={i} id={`otp${i}`} ref={el=>{box.current[i]=el}} inputMode="numeric" maxLength={1} autoComplete={i?'off':'one-time-code'} aria-label={t('Digit {n}',{n:i+1})} placeholder={String(i+1)} value={x} onChange={e=>digit(i,e.target.value)} onKeyDown={e=>{if(e.key==='Backspace'&&!x&&i>0)box.current[i-1]?.focus();if(e.key==='Enter')verify()}}/>)}</div>
      {err&&<div className="e" role="alert">{t(err)}</div>}
      <button type="button" className="btn" disabled={busy} onClick={verify}>{busy?t("Checking..."):t("Verify and login")}</button>
      <div className="center">{left>0?t('Resend OTP in {n} s',{n:left}):<button type="button" className="lk" onClick={send}>{t("Resend OTP")}</button>}</div></>}
  </Shell>;
}
