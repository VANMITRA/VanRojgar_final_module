import {useEffect,useRef,useState} from 'react';
import {useApp} from '../store';
import Shell from './Shell';
import {Done,PHONE_MSG,phoneOk,toHome} from './fields';
import {roleForPhone,sendOtp,verifyOtp} from './auth';

export default function Login(){
  const a=useApp();
  const [step,setStep]=useState<'phone'|'otp'|'done'>('phone');
  const [phone,setPhone]=useState(''),[err,setErr]=useState(''),[busy,setBusy]=useState(false),[left,setLeft]=useState(0);
  const [d,setD]=useState(['','','','','','']),box=useRef<(HTMLInputElement|null)[]>([]);
  useEffect(()=>{if(left<=0)return;const t=setTimeout(()=>setLeft(left-1),1000);return()=>clearTimeout(t)},[left]);

  const send=async()=>{
    if(!phoneOk(phone)){setErr(PHONE_MSG);document.getElementById('ph')?.focus();return}
    setBusy(true);await sendOtp(phone);setBusy(false);
    setErr('');setD(['','','','','','']);setLeft(30);setStep('otp');setTimeout(()=>box.current[0]?.focus(),0);
  };
  const verify=async()=>{
    const c=d.join('');
    if(c.length<6){setErr('Enter all 6 digits.');box.current[d.findIndex(x=>!x)]?.focus();return}
    setBusy(true);const ok=await verifyOtp(phone,c);
    if(!ok){setBusy(false);setErr('That code is not right. Check the SMS and try again.');box.current[0]?.focus();return}
    a.setRole(await roleForPhone(phone));a.setMenu(false);setBusy(false);setStep('done');
  };
  const digit=(i:number,x:string)=>{
    const v=x.replace(/\D/g,'').slice(-1);setErr('');setD(p=>p.map((q,j)=>j===i?v:q));
    if(v&&i<5)box.current[i+1]?.focus();
  };
  const paste=(e:React.ClipboardEvent)=>{
    const t=e.clipboardData.getData('text').replace(/\D/g,'').slice(0,6);if(!t)return;
    e.preventDefault();setD([0,1,2,3,4,5].map(i=>t[i]||''));
  };

  if(step==='done')return <Done title="Welcome to VanRozgar" text="You are logged in."><button type="button" className="btn" onClick={toHome}>Go to Home</button></Done>;
  return <Shell login>
    {step==='phone'?<>
      <h3>Login</h3>
      <label htmlFor="ph">Phone number</label>
      <div className="pill"><span className="pre">+91</span><input id="ph" type="tel" inputMode="numeric" maxLength={10} placeholder="Enter your phone number" value={phone} aria-invalid={!!err} aria-describedby={err?'ph-e':undefined} onChange={e=>{setPhone(e.target.value.replace(/\D/g,''));setErr('')}} onKeyDown={e=>{if(e.key==='Enter')send()}}/></div>
      <div className="hint">We will send a 6-digit code by SMS.</div>
      {err&&<div className="e" id="ph-e" role="alert">{err}</div>}
      <button type="button" className="btn" disabled={busy} onClick={send}>{busy?'Sending...':'Send OTP'}</button>
      <div className="center">Do not have an account?<br/><a className="lk" href="#/signup">Sign up</a></div></>
    :<>
      <h3>Enter the code</h3>
      <div className="sub">Sent to +91 {phone} <button type="button" className="lk" onClick={()=>{setStep('phone');setErr('')}}>Change number</button></div>
      <label htmlFor="otp0">6-digit code</label>
      <div className="otp" onPaste={paste}>{d.map((x,i)=><input key={i} id={`otp${i}`} ref={el=>{box.current[i]=el}} inputMode="numeric" maxLength={1} autoComplete={i?'off':'one-time-code'} aria-label={`Digit ${i+1}`} placeholder={String(i+1)} value={x} onChange={e=>digit(i,e.target.value)} onKeyDown={e=>{if(e.key==='Backspace'&&!x&&i>0)box.current[i-1]?.focus();if(e.key==='Enter')verify()}}/>)}</div>
      {err&&<div className="e" role="alert">{err}</div>}
      <button type="button" className="btn" disabled={busy} onClick={verify}>{busy?'Checking...':'Verify and login'}</button>
      <div className="center">{left>0?`Resend OTP in ${left} s`:<button type="button" className="lk" onClick={send}>Resend OTP</button>}</div></>}
  </Shell>;
}
