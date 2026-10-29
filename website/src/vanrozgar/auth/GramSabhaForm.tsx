import {useState} from 'react';
import {useApp} from '../store';
import {R} from '../data';
import Shell from './Shell';
import {AGREE_MSG,Chk,Done,Errs,FileF,Fw,Head,PHONE_MSG,PhoneBlock,Sel,Submit,Txt,fileErr,phoneOk,req,toHome,useForm} from './fields';
import {VILLAGES} from './VillagerForm';
import {useT} from '../i18n';

const POS=['Adhyaksha (committee chairperson)','Sachiv (committee secretary)','Committee member','Gram Panchayat Secretary (Gram Sevak)','Other'];
type Person={name:string,phone:string,pos:string};
const STEPS=['Gram Sabha details','Your details','Other persons'];
const Bar=({n}:{n:number})=>{const t=useT();return <div className="sbar">{STEPS.map((s,i)=><div key={s} className={i<n?'on':''}><i></i>{t(s)}</div>)}</div>};

export default function GramSabhaForm(){const t=useT();
  const a=useApp();
  const [step,setStep]=useState(1),[done,setDone]=useState(false),[people,setPeople]=useState<Person[]>([]);
  const f=useForm({village:'',taluka:'',district:'',gp:'',cfrNo:'',cfrDate:'',cfrFile:null,meetDate:'',resFile:null,commFile:null,name:'',phone:'',verified:false,position:'',posOther:'',voter:null,terms:false});
  const move=(n:number)=>{setStep(n);scrollTo(0,0)};
  const pickVillage=(x:string)=>{f.set('village')(x);if(R[x]){f.set('taluka')(R[x][0]);f.set('district')('Nashik')}};
  const edit=(i:number,k:keyof Person,x:string)=>{setPeople(p=>p.map((q,j)=>j===i?{...q,[k]:k==='phone'?x.replace(/\D/g,''):x}:q));f.clear(`${({name:"pn",phone:"pp",pos:"pr"})[k]}${i}`)};

  const next=()=>{
    const v=f.v,e:Errs={};
    if(step===1){
      req(e,'village',v.village);req(e,'taluka',v.taluka);req(e,'district',v.district);req(e,'gp',v.gp);req(e,'cfrNo',v.cfrNo);req(e,'cfrDate',v.cfrDate);
      const c=fileErr(v.cfrFile,true);if(c)e.cfrFile=c;
      req(e,'meetDate',v.meetDate);
      const r=fileErr(v.resFile,true);if(r)e.resFile=r;
      const m=fileErr(v.commFile,false);if(m)e.commFile=m;
    }else{
      req(e,'name',v.name);
      if(!phoneOk(v.phone))e.phone=PHONE_MSG;else if(!v.verified)e.phone='Verify your phone with OTP.';
      req(e,'position',v.position);
      if(v.position==='Other')req(e,'posOther',v.posOther);
      const vo=fileErr(v.voter,false);if(vo)e.voter=vo;
    }
    if(f.focusFirst(e))return;
    move(step+1);
  };
  const send=()=>{
    const e:Errs={};
    people.forEach((p,i)=>{req(e,`pn${i}`,p.name);if(!phoneOk(p.phone))e[`pp${i}`]=PHONE_MSG;req(e,`pr${i}`,p.pos)});
    if(!f.v.terms)e.terms=AGREE_MSG;
    /* TODO: send the extra people (people state) with the form */
    f.submit('gram-sabha',e,()=>{a.setRole('gs');setDone(true)});
  };
  if(done)return <Done title={t("Thank you")} chip={t("Waiting for review")} text={t("Our team will check your CFR title and the signed resolution and tell you by SMS.")}><button type="button" className="btn" onClick={toHome}>{t("Go to Home")}</button></Done>;

  return <Shell>
    {step===1&&<><Head title={t("Gram Sabha")} sub={t("Details of your Gram Sabha.")} back="#/signup"/><Bar n={1}/>
      <div className="f2">
        <Fw id="village" label={t("Village")} span err={f.errs.village}><div className="pill"><select id="village" value={f.v.village} onChange={e=>pickVillage(e.target.value)} aria-invalid={!!f.errs.village}><option value="">{t("Choose")}</option>{VILLAGES.map(o=><option key={o} value={o}>{t(o)}</option>)}</select></div></Fw>
        <Txt f={f} id="taluka" label={t("Taluka")}/><Txt f={f} id="district" label={t("District")}/>
        <Txt f={f} id="gp" label={t("Gram Panchayat name")} span/>
        <Txt f={f} id="cfrNo" label={t("CFR title (Form C) number")}/><Txt f={f} id="cfrDate" label={t("Title date")} type="date"/>
        <FileF f={f} id="cfrFile" label={t("Photo or scan of the CFR title")}/>
        <Txt f={f} id="meetDate" label={t("Date of the Gram Sabha meeting")} type="date" span/>
        <FileF f={f} id="resFile" label={t("Signed Gram Sabha resolution naming the 4 authorised persons")}/>
        <FileF f={f} id="commFile" label={t("Committee formation paper")} opt/>
      </div>
      <button type="button" className="btn" onClick={next}>{t("Next")}</button></>}
    {step===2&&<><Head title={t("Your details")} sub={t("You are the first authorised person.")} back={()=>move(1)}/><Bar n={2}/>
      <div className="f2">
        <Txt f={f} id="name" label={t("Full name")} span/>
        <PhoneBlock f={f}/>
        <Sel f={f} id="position" label={t("Position")} options={POS} span/>
        {f.v.position==='Other'&&<Txt f={f} id="posOther" label={t("Your position")} span/>}
        <FileF f={f} id="voter" label={t("Photo of your voter ID")} opt/>
      </div>
      <button type="button" className="btn" onClick={next}>{t("Next")}</button></>}
    {step===3&&<><Head title={t("Add the other persons")} sub={t("Up to 3 more people.")} back={()=>move(2)}/><Bar n={3}/>
      <div style={{fontSize:13,color:'#C7D3B6'}}>{t("{n} of 4 added",{n:1+people.length})}</div>
      {people.map((p,i)=><div key={i} className="pc"><div className="f2">
        <Fw id={`pn${i}`} label={t("Full name")} span err={f.errs[`pn${i}`]}><div className="pill"><input id={`pn${i}`} value={p.name} onChange={e=>edit(i,'name',e.target.value)} aria-invalid={!!f.errs[`pn${i}`]}/></div></Fw>
        <Fw id={`pp${i}`} label={t("Phone number")} span err={f.errs[`pp${i}`]}><div className="pill"><span className="pre">+91</span><input id={`pp${i}`} type="tel" inputMode="numeric" maxLength={10} value={p.phone} onChange={e=>edit(i,'phone',e.target.value)} aria-invalid={!!f.errs[`pp${i}`]}/></div></Fw>
        <Fw id={`pr${i}`} label={t("Position")} span err={f.errs[`pr${i}`]}><div className="pill"><select id={`pr${i}`} value={p.pos} onChange={e=>edit(i,'pos',e.target.value)} aria-invalid={!!f.errs[`pr${i}`]}><option value="">{t("Choose")}</option>{POS.map(o=><option key={o} value={o}>{t(o)}</option>)}</select></div></Fw>
        <div style={{gridColumn:'1/-1'}}><button type="button" className="lk" style={{fontSize:13}} onClick={()=>setPeople(people.filter((_,j)=>j!==i))}>{t("Remove this person")}</button></div>
      </div></div>)}
      {people.length<3&&<button type="button" className="btn o" onClick={()=>setPeople([...people,{name:'',phone:'',pos:''}])}>{t("Add another person")}</button>}
      <div className="note">{t("Only 4 people can use this Gram Sabha account. The Adhyaksha and the Sachiv approve requests and confirm villagers. Other members can enter stock and view. To change a person, upload a new signed resolution.")}</div>
      <Chk f={f} id="terms"/>
      <Submit busy={f.busy} label={t("Send for review")} onClick={send}/></>}
  </Shell>;
}
