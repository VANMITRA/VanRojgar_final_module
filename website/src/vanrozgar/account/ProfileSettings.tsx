import {useState} from 'react';
import {useApp} from '../store';
import {LANGS,useLang,useT} from '../i18n';
import {VIL} from '../helpers';
import {sendOtp,verifyOtp} from '../auth/auth';
import {PHONE_MSG,emailOk,phoneOk} from '../auth/fields';

type Errs=Record<string,string>;

export default function ProfileSettings(){
  const a=useApp(),t=useT(),{lang,setLang}=useLang();
  const [f,setF]=useState(a.profile),[errs,setErrs]=useState<Errs>({});
  const set=(k:string)=>(e:{target:{value:string}})=>{setF(o=>({...o,[k]:e.target.value}));setErrs(o=>{if(!o[k])return o;const n={...o};delete n[k];return n})};

  const save=()=>{
    const e:Errs={};
    if(f.name.trim().length<2)e.name=t('Enter your name.');
    if(f.email.trim()&&!emailOk(f.email))e.email=t('Enter a valid email address.');
    setErrs(e);
    const ids=Object.keys(e);
    if(ids.length){document.getElementById('pf-'+ids[0])?.focus();return}
    /* TODO: save the profile on the server */
    a.setProfile({...f,name:f.name.trim(),email:f.email.trim(),address:f.address.trim()});
    a.toast(t('Saved.'));
  };

  /* Changing the phone number needs a code sent by SMS */
  const [step,setStep]=useState<'view'|'new'|'code'>('view'),[np,setNp]=useState(''),[code,setCode]=useState(''),[pe,setPe]=useState(''),[busy,setBusy]=useState(false);
  const sendCode=async()=>{
    if(!phoneOk(np)){setPe(t(PHONE_MSG));return}
    if(np===a.phone){setPe(t('This is already your number.'));return}
    setBusy(true);await sendOtp(np);setBusy(false);setPe('');setCode('');setStep('code');
  };
  const verify=async()=>{
    setBusy(true);const ok=await verifyOtp(np,code);setBusy(false);
    if(!ok){setPe(t('That code is not right. Check the SMS and try again.'));return}
    a.setPhone(np);setStep('view');setNp('');setPe('');a.toast(t('Phone number changed.'));
  };

  const err=(k:string)=>errs[k]?<div className="rq-err" id={'pe-'+k} role="alert">{errs[k]}</div>:null;
  const inp=(k:'name'|'email'|'address',props:any={},Tag:'input'|'textarea'='input')=>{const C=Tag as any;return <C id={'pf-'+k} value={f[k]} onChange={set(k)} aria-invalid={!!errs[k]} aria-describedby={errs[k]?'pe-'+k:undefined} {...props}/>};

  return <div className="rq-page">
    <h1>{t('Profile and settings')}</h1><div className="sub">{t('See and change your details.')}</div>
    <div className="rq-g" style={{gridTemplateColumns:'minmax(0,1.4fr) minmax(0,1fr)'}}>
      <div className="rq-card">
        <h2 style={{fontSize:15}}>{t('Your details')}</h2>
        <label htmlFor="pf-name">{t('Full name')}</label>{inp('name',{autoComplete:'name'})}{err('name')}
        <label htmlFor="pf-email">{t('Email')} <span className="rq-opt">({t('optional')})</span></label>{inp('email',{type:'email',autoComplete:'email'})}{err('email')}
        <label htmlFor="pf-address">{t('Address')} <span className="rq-opt">({t('optional')})</span></label>{inp('address',{style:{minHeight:56}},'textarea')}
        <label htmlFor="pf-village">{t('Village')} <span className="rq-opt">({t('optional')})</span></label>
        <select id="pf-village" value={f.village} onChange={set('village')}><option value="">{t('Choose')}</option>{VIL.map(v=><option key={v} value={v}>{v}</option>)}</select>
        <button type="button" className="b1 rq-full" onClick={save}>{t('Save')}</button>
      </div>
      <div style={{display:'grid',gap:16,alignSelf:'start'}}>
        <div className="rq-card">
          <h2 style={{fontSize:15}}>{t('Phone number')}</h2>
          <div className="kv"><span>{t('Number')}</span><span>+91 {a.phone||'—'}</span></div>
          {step==='view'&&<button type="button" className="b2" style={{marginTop:10}} onClick={()=>setStep('new')}>{t('Change number')}</button>}
          {step==='new'&&<><label htmlFor="pf-np">{t('New phone number')}</label><div className="pill"><span className="pre">+91</span><input id="pf-np" inputMode="numeric" maxLength={10} value={np} onChange={e=>{setNp(e.target.value.replace(/\D/g,''));setPe('')}}/></div>
            {pe&&<div className="rq-err" role="alert">{pe}</div>}<div className="rq-hint">{t('We will send a 6-digit code by SMS.')}</div>
            <div className="row" style={{marginTop:10}}><button type="button" className="b1" disabled={busy} onClick={sendCode}>{busy?t('Sending...'):t('Send OTP')}</button><button type="button" className="b2" onClick={()=>{setStep('view');setPe('')}}>{t('Cancel')}</button></div></>}
          {step==='code'&&<><label htmlFor="pf-code">{t('6-digit code')}</label><input id="pf-code" inputMode="numeric" maxLength={6} value={code} onChange={e=>{setCode(e.target.value.replace(/\D/g,''));setPe('')}}/>
            {pe&&<div className="rq-err" role="alert">{pe}</div>}<div className="rq-hint">{t('Sent to +91 {phone}',{phone:np})}</div>
            <div className="row" style={{marginTop:10}}><button type="button" className="b1" disabled={busy||code.length<6} onClick={verify}>{busy?t('Checking...'):t('Verify and change')}</button><button type="button" className="b2" onClick={()=>{setStep('new');setPe('')}}>{t('Back')}</button></div></>}
        </div>
        <div className="rq-card">
          <h2 style={{fontSize:15}}>{t('Language')}</h2>
          <div className="row" role="group" aria-label={t('Language')}>{LANGS.map(([c,,n])=><button key={c} type="button" lang={c} className={`fc${lang===c?' on':''}`} aria-pressed={lang===c} onClick={()=>setLang(c)}>{n}</button>)}</div>
          <h2 style={{fontSize:15,marginTop:14}}>{t('Theme')}</h2>
          <div className="row" role="group" aria-label={t('Theme')}>{[['light','Light'],['dark','Dark']].map(x=><button key={x[0]} type="button" className={`fc${a.theme===x[0]?' on':''}`} aria-pressed={a.theme===x[0]} onClick={()=>{if(a.theme!==x[0])a.toggleTheme()}}>{t(x[1])}</button>)}</div>
        </div>
      </div>
    </div>
  </div>;
}
