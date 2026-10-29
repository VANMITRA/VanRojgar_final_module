import {useState} from 'react';
import Shell from './Shell';
import {Chips,Done,Errs,FileF,Head,Submit,Txt,fileErr,req,toHome,useForm} from './fields';

const PR=['Bamboo poles','Moh flowers and seeds','Tamarind','Awla','Raw cashew nuts','Mango','Behda','Hirda','Custard apple','Jamun','Bael','Ber','Karanj seeds','Other'];

export default function SellForm(){
  const [done,setDone]=useState(false);
  const f=useForm({prod:{} as Record<string,boolean>,amt:{} as Record<string,string>,survey:'',area:'',where:'',crops:'',lt:'',r712:null,ifr:null,photos:[]});
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
    f.submit('sell',e,()=>setDone(true));
  };
  if(done)return <Done title="Thank you" chip="Waiting for review" text="Our team checks every document."><button type="button" className="btn" onClick={toHome}>Go to Home</button></Done>;
  return <Shell>
    <Head title="What do you want to sell?" sub="Our team checks every document." back="#/signup/villager"/>
    <label>Products</label>
    <div className="row">{PR.map((p,i)=><button key={p} type="button" id={'prod'+i} className={`tc${f.v.prod[i]?' on':''}`} aria-pressed={!!f.v.prod[i]} onClick={()=>toggle(i)}>{p}</button>)}</div>
    {f.errs.prod0&&<div className="e" role="alert">{f.errs.prod0}</div>}
    {PR.map((p,i)=>f.v.prod[i]?<div key={p}><div className="pl"><span>{p}</span><div className="pill sm"><input id={'amt'+i} inputMode="numeric" placeholder="per year" aria-label={`Yearly amount of ${p}`} value={f.v.amt[i]||''} onChange={e=>amt(i,e.target.value)} aria-invalid={!!f.errs['amt'+i]}/><span className="pre">{i===0?'poles':'kg'}</span></div></div>{f.errs['amt'+i]&&<div className="e" role="alert">{f.errs['amt'+i]}</div>}</div>:null)}
    <div className="pc"><div className="f2">
      <Txt f={f} id="survey" label="Survey number"/><Txt f={f} id="area" label="Land area" im/>
      <Txt f={f} id="where" label="Where is the land? (village, taluka)" span/>
      <Txt f={f} id="crops" label="Crops or trees that grow there" span/>
    </div></div>
    <label>Land type</label>
    <Chips id="lt" options={['My own land','Individual forest rights land','Community forest']} value={f.v.lt} onPick={f.set('lt')} err={f.errs.lt}/>
    <div className="f2">
      <FileF f={f} id="r712" label="7/12 extract" opt/>
      <FileF f={f} id="ifr" label="Individual forest rights title" opt/>
      <FileF f={f} id="photos" label="Photos of the land and produce" opt multiple/>
    </div>
    <Submit busy={f.busy} label="Send for review" onClick={go}/>
  </Shell>;
}
