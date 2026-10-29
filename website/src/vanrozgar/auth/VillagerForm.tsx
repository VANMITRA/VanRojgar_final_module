import {useState} from 'react';
import {useApp} from '../store';
import Shell from './Shell';
import {Chk,Done,Errs,FileF,Head,PhoneBlock,Sel,Submit,Txt,contactErrs,fileErr,pinOk,req,useForm} from './fields';

export const VILLAGES=['Ambaee','Bhatode','Chakore','Devgaon','Dongargaon','Kanchane','Kochargaon','Kumbharde','Met Chandrachi','Pahine','Take Harsh','Talvaade','Varshi','Waghera','My village is not listed'];

export default function VillagerForm(){
  const a=useApp();const [done,setDone]=useState(false),[help,setHelp]=useState(false);
  const f=useForm({name:'',phone:'',verified:false,email:'',hamlet:'',village:'',taluka:'',district:'',state:'',pin:'',gs:'',letter:null,terms:false});
  const go=()=>{
    const v=f.v,e:Errs={};
    contactErrs(v,e);
    req(e,'hamlet',v.hamlet);req(e,'village',v.village);req(e,'taluka',v.taluka);req(e,'district',v.district);req(e,'state',v.state);
    if(!pinOk(v.pin))e.pin='Enter a 6-digit PIN code.';
    req(e,'gs',v.gs);
    const m=fileErr(v.letter,true);if(m)e.letter=m;
    if(!v.terms)e.terms='Please agree to continue.';
    f.submit('villager',e,()=>{a.setRole('vil');a.setUser({name:f.v.name,phone:f.v.phone});setDone(true)});
  };
  if(done)return <Done title="Account created" chip="Waiting for your Gram Sabha to confirm" text="Our team checks every document.">
    <div className="hl"><b>Want to sell something? Register more</b>Tell us what you grow and which land it comes from.<button type="button" className="btn" style={{marginTop:10}} onClick={()=>{location.hash='#/signup/villager/sell'}}>Register more</button></div></Done>;
  return <Shell>
    <Head title="CFR villager" sub="Tell us who you are and where you live." back="#/signup"/>
    <div className="f2">
      <Txt f={f} id="name" label="Full name" span/>
      <PhoneBlock f={f}/>
      <Txt f={f} id="email" label="Email" type="email" span/>
      <Txt f={f} id="hamlet" label="Hamlet or ward"/><Txt f={f} id="village" label="Village"/><Txt f={f} id="taluka" label="Taluka"/>
      <Txt f={f} id="district" label="District"/><Txt f={f} id="state" label="State"/><Txt f={f} id="pin" label="PIN code" im max={6}/>
      <Sel f={f} id="gs" label="Your Gram Sabha" options={VILLAGES} span/>
      <FileF f={f} id="letter" label="Signed letter from your Gram Sabha"/>
    </div>
    <div className="note"><button type="button" className="lk" aria-expanded={help} onClick={()=>setHelp(!help)}>What should the letter say?</button>{help&&<div style={{marginTop:6}}>We confirm that [full name], phone [number], lives in our village and is a member of our Gram Sabha. Signed by the Adhyaksha and the Sachiv, with date and seal.</div>}</div>
    <Chk f={f} id="terms"/>
    <Submit busy={f.busy} label="Create account" onClick={go}/>
  </Shell>;
}
