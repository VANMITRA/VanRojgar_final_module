import {ReactNode,useState} from 'react';
import Shell from './Shell';
import {useT,useTParts} from '../i18n';
import {sendOtp,verifyOtp,submitForm} from './auth';

export type Errs=Record<string,string>;
export const phoneOk=(s:string)=>/^[6-9][0-9]{9}$/.test(s);
export const pinOk=(s:string)=>/^[0-9]{6}$/.test(s);
export const emailOk=(s:string)=>/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(s.trim());
export const PHONE_MSG='Enter a 10-digit number that starts with 6, 7, 8 or 9.';
const TYPES=['image/jpeg','image/png','application/pdf'];
export function fileErr(x:File|File[]|null,required:boolean){
  const a=Array.isArray(x)?x:x?[x]:[];
  if(!a.length)return required?'Upload a file (jpg, png or pdf, up to 5 MB).':'';
  for(const f of a){
    if(!TYPES.includes(f.type)||f.size>5*1024*1024)return 'Use a jpg, png or pdf file up to 5 MB.';
  }
  return '';
}
export const req=(e:Errs,id:string,val:string,msg='This field is required.')=>{if(!String(val).trim())e[id]=msg};

export function useForm(init:Record<string,any>){
  const [v,setV]=useState(init),[errs,setErrs]=useState<Errs>({}),[busy,setBusy]=useState(false);
  const clear=(k:string)=>setErrs(p=>{if(!p[k])return p;const n={...p};delete n[k];return n});
  const set=(k:string)=>(x:any)=>{setV(p=>({...p,[k]:x}));clear(k)};
  const focusFirst=(e:Errs)=>{const ids=Object.keys(e);setErrs(e);if(ids.length)setTimeout(()=>document.getElementById(ids[0])?.focus(),0);return ids.length>0};
  const submit=async(kind:string,e:Errs,done:()=>void)=>{
    if(focusFirst(e))return;
    setBusy(true);await submitForm(kind,v);setBusy(false);done();
  };
  return {v,set,errs,busy,submit,focusFirst,clear,setErrs};
}
export type F=ReturnType<typeof useForm>;

type FwP={id:string,label?:string,opt?:boolean,span?:boolean,err?:string,children:ReactNode};
export const Fw=({id,label,opt,span,err,children}:FwP)=>{const t=useT();return <div className="fw" style={span?{gridColumn:'1/-1'}:undefined}>{label&&<label htmlFor={id}>{label}{opt&&<> <span className="opt">({t('optional')})</span></>}</label>}{children}{err&&<div className="e" id={id+'-e'} role="alert">{t(err)}</div>}</div>};
const aria=(id:string,err?:string)=>({'aria-invalid':!!err,'aria-describedby':err?id+'-e':undefined});

export function Txt({f,id,label,opt,span,pre,type='text',im,max,ph}:{f:F,id:string,label:string,opt?:boolean,span?:boolean,pre?:string,type?:string,im?:boolean,max?:number,ph?:string}){
  const err=f.errs[id];
  return <Fw id={id} label={label} opt={opt} span={span} err={err}><div className="pill">{pre&&<span className="pre">{pre}</span>}<input id={id} type={type} inputMode={im?'numeric':undefined} maxLength={max} placeholder={ph} value={f.v[id]} onChange={e=>f.set(id)(im?e.target.value.replace(/\D/g,''):e.target.value)} {...aria(id,err)}/></div></Fw>;
}
export function Sel({f,id,label,options,span}:{f:F,id:string,label:string,options:string[],span?:boolean}){
  const err=f.errs[id],t=useT();
  return <Fw id={id} label={label} span={span} err={err}><div className="pill"><select id={id} value={f.v[id]} onChange={e=>f.set(id)(e.target.value)} {...aria(id,err)}><option value="">{t('Choose')}</option>{options.map(o=><option key={o} value={o}>{t(o)}</option>)}</select></div></Fw>;
}
export function FileF({f,id,label,opt,multiple}:{f:F,id:string,label:string,opt?:boolean,multiple?:boolean}){
  const t=useT(),err=f.errs[id],x=f.v[id],name=Array.isArray(x)?x.map((q:File)=>q.name).join(', '):x?.name;
  return <Fw id={id} label={label} opt={opt} span err={err}>
    <label className="file" htmlFor={id} style={{margin:0}}><i className="ti ti-upload"></i><span>{name||t('Choose a file (jpg, png or pdf, up to 5 MB)')}</span></label>
    <input id={id} type="file" className="sr" multiple={multiple} accept=".jpg,.jpeg,.png,.pdf" {...aria(id,err)} onChange={e=>{
      const l=Array.from(e.target.files||[]);if(!l.length)return;
      const m=fileErr(l,false);
      if(m){e.target.value='';f.setErrs(p=>({...p,[id]:m}));return}
      f.set(id)(multiple?l:l[0]);
    }}/></Fw>;
}
export function Chips({id,options,value,onPick,err}:{id:string,options:string[],value:string,onPick:(s:string)=>void,err?:string}){
  const t=useT();
  return <><div className="row" role="group">{options.map((o,i)=><button key={o} type="button" id={i?undefined:id} className={`tc${o===value?' on':''}`} aria-pressed={o===value} onClick={()=>onPick(o)}>{t(o)}</button>)}</div>{err&&<div className="e" role="alert">{t(err)}</div>}</>;
}
export const AGREE_MSG='Tick the box to agree to the Terms and conditions and the Privacy policy.';
/* Required box with links to the Terms and the Privacy policy, opened in a new tab */
export function AgreeBox({id,checked,onChange,err}:{id:string,checked:boolean,onChange:(b:boolean)=>void,err?:string}){
  const t=useT(),parts=useTParts();
  const link=(h:string,x:string)=><a className="lk" href={h} target="_blank" rel="noopener noreferrer">{t(x)}</a>;
  return <><label className="chk"><input type="checkbox" id={id} checked={checked} onChange={e=>onChange(e.target.checked)} {...aria(id,err)}/> <span>{parts('I agree to the {terms} and the {privacy}.',{terms:link('#/impact/terms','Terms and conditions'),privacy:link('#/impact/privacy','Privacy policy')})}</span></label>{err&&<div className="e" id={id+'-e'} role="alert">{t(err)}</div>}</>;
}
export function Chk({f,id}:{f:F,id:string}){
  return <AgreeBox id={id} checked={!!f.v[id]} onChange={f.set(id)} err={f.errs[id]}/>;
}

/* Phone number with OTP check. DEV code: 123456 (see auth.ts) */
export function PhoneBlock({f,id='phone',span=true}:{f:F,id?:string,span?:boolean}){
  const t=useT();
  const [sent,setSent]=useState(false),[code,setCode]=useState(''),[ce,setCe]=useState(''),[busy,setBusy]=useState(false);
  const ok=!!f.v.verified,err=f.errs[id];
  const send=async()=>{
    if(!phoneOk(f.v[id])){f.setErrs(p=>({...p,[id]:PHONE_MSG}));document.getElementById(id)?.focus();return}
    setBusy(true);await sendOtp(f.v[id]);setBusy(false);setSent(true);f.clear(id);
  };
  const verify=async()=>{
    setBusy(true);const good=await verifyOtp(f.v[id],code);setBusy(false);
    if(good){f.set('verified')(true);setCe('')}else{setCe('That code is not right. Check the SMS and try again.');document.getElementById(id+'-code')?.focus()}
  };
  return <div className="fw" style={span?{gridColumn:'1/-1'}:undefined}><label htmlFor={id}>{t('Phone number')}</label>
    <div className="pill"><span className="pre">+91</span><input id={id} type="tel" inputMode="numeric" maxLength={10} placeholder={t('10-digit number')} readOnly={ok} value={f.v[id]} onChange={e=>{f.set(id)(e.target.value.replace(/\D/g,''));f.set('verified')(false);setSent(false)}} aria-invalid={!!err} aria-describedby={err?id+'-e':undefined}/>
      {ok?<span className="vf"><i className="ti ti-circle-check"></i> {t('Verified')}</span>:<button type="button" className="lk" disabled={busy} onClick={send}>{t('Send OTP')}</button>}</div>
    {err&&<div className="e" id={id+'-e'} role="alert">{t(err)}</div>}
    {sent&&!ok&&<><div className="pill" style={{marginTop:8}}><input id={id+'-code'} inputMode="numeric" maxLength={6} placeholder={t('6-digit code')} aria-label={t('6-digit code')} value={code} onChange={e=>{setCode(e.target.value.replace(/\D/g,''));setCe('')}}/><button type="button" className="lk" disabled={busy} onClick={verify}>{t('Verify')}</button></div>{ce&&<div className="e" role="alert">{t(ce)}</div>}</>}
  </div>;
}

export function contactErrs(v:any,e:Errs){
  req(e,'name',v.name);
  if(!phoneOk(v.phone))e.phone=PHONE_MSG;else if(!v.verified)e.phone='Verify your phone with OTP.';
  if(!emailOk(v.email))e.email='Enter a valid email.';
}

export const Head=({title,sub,back}:{title:string,sub?:string,back?:string|(()=>void)})=>{const t=useT();return <>{back&&(typeof back==='string'?<a className="lk" style={{fontSize:13,marginBottom:6,display:'block'}} href={back}>&lsaquo; {t('Back')}</a>:<button type="button" className="lk" style={{fontSize:13,marginBottom:6,display:'block'}} onClick={back}>&lsaquo; {t('Back')}</button>)}<h3>{title}</h3>{sub&&<div className="sub">{sub}</div>}</>};
export const Submit=({busy,label,onClick}:{busy:boolean,label:string,onClick:()=>void})=>{const t=useT();return <button type="button" className="btn" disabled={busy} onClick={onClick}>{busy?t('Sending...'):label}</button>};
export function Done({title,chip,text,children}:{title:string,chip?:string,text:string,children?:ReactNode}){
  return <Shell><div className="ok"><i className="ti ti-check"></i></div><h3>{title}</h3>{chip&&<span className="chip2">{chip}</span>}<div style={{color:'#C7D3B6',margin:'10px 0'}}>{text}</div>{children}</Shell>;
}
export const toHome=()=>{location.hash='#/'};
