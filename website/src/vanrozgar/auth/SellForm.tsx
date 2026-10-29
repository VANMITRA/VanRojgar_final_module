import {useState} from 'react';
import Shell from './Shell';
import {AGREE_MSG,Chips,Chk,Done,Errs,FileF,Head,Submit,Txt,fileErr,req,toHome,useForm} from './fields';
import {useT} from '../i18n';

const PR=['Bamboo poles','Moh flowers and seeds','Tamarind','Awla','Raw cashew nuts','Mango','Behda','Hirda','Custard apple','Jamun','Bael','Ber','Karanj seeds','Other'];

export default function SellForm(){const t=useT();
  const [done,setDone]=useState(false);
  const f=useForm({prod:{} as Record<string,boolean>,amt:{} as Record<string,string>,survey:'',area:'',where:'',crops:'',lt:'',r712:null,ifr:null,photos:[],terms:false});
  const toggle=(i:number)=>{f.set('prod')({...f.v.prod,[i]:!f.v.prod[i]});f.clear('amt'+i)};
  const amt=(i:number,x:string)=>{f.set('amt')({...f.v.amt,[i]:x.replace(/\D/g,'')});f.clear('amt'+i)};
  const go=()=>{
    const v=f.v,e:Errs={};
    const on=PR.map((_,i)=>i).filter(i=>v.prod[i]);
    if(!on.length)e.prod0='Tick at least one product.';
    on.forEach(i=>{if(!(+v.amt[i]>0))e['amt'+i]='Enter a yearly amount.'});
    req(e,'survey',v.survey);req(e,'area',v.area);req(e,'where',v.where);req(e,'crops',v.crops);
    if(!v.lt)e.lt='Choose the land type.';
    (['r712','ifr','photos'] as const).forEach(k=>{const m=fileErr(v[k],false);if(m)e[k]=m});
    if(!v.terms)e.terms=AGREE_MSG;
    f.submit('sell',e,()=>setDone(true));
  };
  if(done)return <Done title={t("Thank you")} chip={t("Waiting for review")} text={t("Our team checks every document.")}><button type="button" className="btn" onClick={toHome}>{t("Go to Home")}</button></Done>;
  return <Shell>
    <Head title={t("What do you want to sell?")} sub={t("Our team checks every document.")} back="#/signup/villager"/>
    <label>{t("Products")}</label>
    <div className="row">{PR.map((p,i)=><button key={p} type="button" id={'prod'+i} className={`tc${f.v.prod[i]?' on':''}`} aria-pressed={!!f.v.prod[i]} onClick={()=>toggle(i)}>{t(p)}</button>)}</div>
    {f.errs.prod0&&<div className="e" role="alert">{t(f.errs.prod0)}</div>}
    {PR.map((p,i)=>f.v.prod[i]?<div key={p}><div className="pl"><span>{t(p)}</span><div className="pill sm"><input id={'amt'+i} inputMode="numeric" placeholder={t("per year")} aria-label={t('Yearly amount of {p}',{p:t(p)})} value={f.v.amt[i]||''} onChange={e=>amt(i,e.target.value)} aria-invalid={!!f.errs['amt'+i]}/><span className="pre">{i===0?t("poles"):t("kg")}</span></div></div>{f.errs['amt'+i]&&<div className="e" role="alert">{t(f.errs['amt'+i])}</div>}</div>:null)}
    <div className="pc"><div className="f2">
      <Txt f={f} id="survey" label={t("Survey number")}/><Txt f={f} id="area" label={t("Land area")} im/>
      <Txt f={f} id="where" label={t("Where is the land? (village, taluka)")} span/>
      <Txt f={f} id="crops" label={t("Crops or trees that grow there")} span/>
    </div></div>
    <label>{t("Land type")}</label>
    <Chips id="lt" options={['My own land','Individual forest rights land','Community forest']} value={f.v.lt} onPick={f.set('lt')} err={f.errs.lt}/>
    <div className="f2">
      <FileF f={f} id="r712" label={t("7/12 extract")} opt/>
      <FileF f={f} id="ifr" label={t("Individual forest rights title")} opt/>
      <FileF f={f} id="photos" label={t("Photos of the land and produce")} opt multiple/>
    </div>
    <Chk f={f} id="terms"/>
    <Submit busy={f.busy} label={t("Send for review")} onClick={go}/>
  </Shell>;
}
