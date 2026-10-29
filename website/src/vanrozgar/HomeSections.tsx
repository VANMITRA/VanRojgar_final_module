import {useEffect,useRef,useState} from 'react';
import {useApp} from './store';
import {R} from './data';
import {SHOW_BARTER,fgs,APK_URL,Pic,S,VIL,byId,nf,sum} from './helpers';
import {CATS} from './catalog';
import {Price} from './Card';
import details from './resourceDetails.json';
import {PACKS,useLang,useT} from './i18n';

const go=(h:string)=>{location.hash=h};
const MON=['January','February','March','April','May','June','July','August','September','October','November','December'];
const D=details as any[];
const Head=({t,s,id,c}:{t:string,s?:string,id?:string,c?:boolean})=><div id={id} style={{marginBottom:12,textAlign:c?'center':undefined}}><h2 style={{fontSize:22}}>{t}</h2>{s&&<div className="sub">{s}</div>}</div>;
const Sec=({children}:{children:any})=><section className="sec hs">{children}</section>;

/* Season windows in months (1 to 12). A window can wrap past December. The order is used to break ties. */
const WIN:[string,number,number][]=[['custard',9,12],['awla',11,2],['behda',11,1],['hirda',11,1],['ber',1,3],['tamarind',2,4],['cashew',3,5],['bael',3,6],['moh',3,4],['mango',4,6],['jamun',5,7],['karanj',4,6]];
const back=(m:number,from:number)=>(m-from+12)%12; /* months since `from` */

function Promo({bg,eyebrow,title,text,btn,to,img,alt}:{bg:string,eyebrow:string,title:string,text:string,btn:string,to:string,img?:string,alt?:string}){
  return <div className="hs-pb" style={{background:bg}}>
    <div className="hs-pt"><div className="eyebrow">{eyebrow}</div><h3>{title}</h3><p>{text}</p><button className="b1" onClick={()=>go(to)}>{btn} <i className="ti ti-arrow-right"></i></button></div>
    {img&&<div className="hs-pi"><img src={img} alt={alt} loading="lazy" decoding="async"/></div>}
  </div>;
}
function Promos(){const t=useT();
  return <div className="hs-pr">
    {SHOW_BARTER?<Promo bg="var(--band)" eyebrow={t("For Gram Sabhas")} title={t("Swap what you have for what you need")} text={t("Villages with extra bamboo or fruit can trade with villages that lack it. No money needed.")} btn={t("Go to Barter")} to="#/barter"/>
    :<Promo bg="var(--band)" eyebrow={t("For Gram Sabhas and villagers")} title={t("Sell with VanRozgar")} text={t("List your forest produce and reach buyers across Nashik. Every sale gives work to the village.")} btn={t("Sign up")} to="#/signup" img="assets/images/promo-sell.jpg" alt={t("Villagers packing forest produce to sell")}/>}
    <Promo bg="var(--tint)" eyebrow={t("For drivers and riders")} title={t("Deliver with us")} text={t("Carry forest goods from villages to buyers and earn on every trip.")} btn={t("Deliver with us")} to="#/deliver" img="assets/images/promo-deliver.jpg" alt={t("A delivery partner carrying forest produce to a buyer")}/>
  </div>;
}

function ShopVillages(){const t=useT();
  const vs=[...VIL].sort((x,y)=>S[y].length-S[x].length).slice(0,6);
  return <Sec><Head t={t("Shop by Gram Sabha")} s={t("Buy straight from the village that grows it.")}/>
    <div className="fg" style={fgs(vs.length)}>{vs.map(v=><div key={v} className="st hs-v" onClick={()=>go('#/gram-sabha/'+encodeURIComponent(v))}>
      <div className="row" style={{gap:6,flexWrap:'nowrap'}}>{S[v].slice(0,3).map(x=><div key={x[0]} className="mini" style={{flex:1,width:'auto'}}><Pic k={x[0]} kind={byId[x[0]].k} col={byId[x[0]].c}/></div>)}</div>
      <div className="nm" style={{marginTop:8,fontSize:16}}>{v}</div><div className="lc">{t("{taluka}, Nashik",{taluka:t(R[v][0])})}</div>
      <div className="lc" style={{margin:'4px 0 8px'}}>{t("{n} products · {ha} ha of forest",{n:S[v].length,ha:nf(R[v][1])})}</div>
      <button type="button" className="b2" style={{width:'100%',justifyContent:'center'}}>{t("View Gram Sabha")}</button></div>)}</div></Sec>;
}

function Groups(){const t=useT();
  return <Sec><Head t={t("Browse by group")} s={t("Pick a group to see what it holds.")}/>
    <div className="fg" style={fgs(CATS.length)}>{CATS.map(([g,ks])=><div key={g} className="hs-g" onClick={()=>go('#/resources')}>
      <div className="im"><Pic k={ks[0]} kind="tree" col="#8DB85A"/></div><div className="gl"><b>{t(g)}</b><span>{t(ks.length>1?"{n} resources":"{n} resource",{n:ks.length})}</span></div></div>)}</div></Sec>;
}

function Season(){const t=useT();
  const a=useApp(),m=new Date().getMonth()+1;
  const left=(i:number)=>WIN[i][2],start=(i:number)=>WIN[i][1];
  const idx=WIN.map((_,i)=>i);
  const best=(c:number[],key:(i:number)=>number)=>c.reduce((b,i)=>b<0||key(i)<key(b)?i:b,-1);
  const live=idx.filter(i=>back(m,start(i))<=back(left(i),start(i)));
  const rest=(x:number[])=>idx.filter(i=>!live.includes(i)&&!x.includes(i));
  const nextKey=(i:number)=>back(start(i),m);
  const endKey=(i:number)=>back(m,left(i));
  let now=best(live,i=>back(m,start(i)));
  const upIfNoNow=now<0?best(rest([]),nextKey):-1;
  if(now<0)now=upIfNoNow;
  const past=best(rest([now]),endKey),up=best(rest([now,past]),nextKey);
  const mn=(k:number)=>t(MON[k-1]);
  const small=(i:number,cls:string,label:string,txt:string)=>{const k=WIN[i][0],p=byId[k];return <div className={`ss-w ${cls}`}><div className="ss-l">{t(label)}</div>
    <div className="ss-c" onClick={()=>a.openP(k)} role="button" tabIndex={0} onKeyDown={e=>{if(e.key==='Enter')a.openP(k)}}><div className="ss-i"><Pic k={k} kind={p.k} col={p.c}/></div><div className="nm">{t(p.n)}</div><div className="lc">{txt}</div></div></div>};
  const k=WIN[now][0],p=byId[k],ripe=back(m,start(now))<=back(left(now),start(now));
  return <Sec><div style={{textAlign:'center',marginBottom:14}}><h2 style={{fontSize:22}}>{t("In season")}</h2><div className="sub">{t("What is ripe now, and what comes before and after.")}</div></div>
    <div className="ss">
      {small(past,'ss-p','Past',t('Ended in {month}',{month:mn(left(past))}))}
      <div className="ss-w ss-n"><div className="ss-l">{t("Present")}</div>
        <div className="ss-c ss-big"><div className="ss-i"><Pic k={k} kind={p.k} col={p.c}/></div>
          <div className="nm" style={{fontSize:18}}>{t(p.n)}</div>
          <div className="lc">{ripe?t('Ripe {from} to {to}',{from:mn(start(now)),to:mn(left(now))}):t('Starts in {month}',{month:mn(start(now))})}</div>
          <div className="rd" style={{WebkitLineClamp:1}}>{t(p.a)}</div>
          <div className="pc" style={{margin:'6px 0'}}><Price k={k}/></div>
          <button type="button" className="b1" onClick={()=>a.openP(k)}>{t("View")}</button></div></div>
      {small(up,'ss-u','Upcoming',t('Starts in {month}',{month:mn(start(up))}))}
    </div></Sec>;
}

const STEPS=[['search','Find','Search or browse the resources you need.'],['map-pin','Check','See which Gram Sabha has it, how far it is and the price.'],['shopping-cart','Add to cart','Tap the plus button on each card you want.'],['send','Send a request','Send your request to the Gram Sabha. No payment on the site.'],['circle-check','Get an answer','The Gram Sabha accepts, counters or says no. You see it in My requests.'],['truck','Pick up or delivery','Collect it from the village or ask for delivery.']];
function How(){const t=useT();
  return <Sec><Head t={t("How it works")} s={t("Six simple steps from the forest to you.")}/>
    <div className="hs-how">{STEPS.map((x,i)=><div key={x[1]} className="st hs-s"><span className="hs-n">{i+1}</span><i className={`ti ti-${x[0]}`}></i><div className="nm" style={{fontSize:15}}>{t(x[1])}</div><div className="lc">{t(x[2])}</div></div>)}</div></Sec>;
}

const WHY=[['shield-check','Verified source','Every product comes from a Gram Sabha with community forest rights.'],['map-pin','Distance shown','You see where it comes from and how far it is.'],['tag','Fair price','Prices are shown before you ask. The Gram Sabha confirms the final amount.'],['users','Work for villages','Every sale gives work and income to a forest village.'],['plant','Grown in the forest','Villagers plant and care for these forests, and harvest only what is ready.'],['messages','Clear answers','You always see the status of your request: pending, counter offer, accepted or rejected.']];
function Why(){const t=useT();
  return <Sec><Head t={t("Why VanRozgar")} s={t("Why people buy from the village directly.")}/>
    <div className="fg" style={fgs(WHY.length)}>{WHY.map(x=><div key={x[1]} className="st hs-s"><i className={`ti ti-${x[0]}`}></i><div className="nm" style={{fontSize:15}}>{t(x[1])}</div><div className="lc">{t(x[2])}</div></div>)}</div></Sec>;
}

function Count({to}:{to:number}){
  const ref=useRef<HTMLDivElement>(null),[v,setV]=useState(0);
  useEffect(()=>{
    const el=ref.current;if(!el)return;
    if(matchMedia('(prefers-reduced-motion: reduce)').matches||!('IntersectionObserver' in window)){setV(to);return}
    let raf=0;const io=new IntersectionObserver(es=>{if(!es[0].isIntersecting)return;io.disconnect();const t0=performance.now();
      const tick=(t:number)=>{const p=Math.min(1,(t-t0)/1400);setV(Math.round(to*(1-Math.pow(1-p,3))));if(p<1)raf=requestAnimationFrame(tick)};raf=requestAnimationFrame(tick)});
    io.observe(el);return()=>{io.disconnect();cancelAnimationFrame(raf)};
  },[to]);
  return <div ref={ref} className="big" style={{fontSize:28}}>{nf(v)}</div>;
}
function Impact(){const t=useT();
  const T:[number,string][]=[[VIL.length,'Gram Sabhas'],[sum(0),'Hectares of community forest'],[sum(1),'Saplings planted'],[sum(2),'Forest ponds built'],[sum(4),'Loose boulder structures'],[sum(5),'Labour days of work']];
  return <Sec><Head t={t("Our impact")} s={t("Numbers from the records of 14 Gram Sabhas in Nashik district.")}/>
    <div className="fg" style={fgs(T.length)}>{T.map(x=><div key={x[1]} className="st hs-c"><Count to={x[0]}/><div className="lc">{t(x[1])}</div></div>)}</div>
    <div style={{marginTop:12}}><button className="b2" onClick={()=>go('#/impact')}>{t("See all our impact")} <i className="ti ti-arrow-right"></i></button></div></Sec>;
}

const ART=['bamboo','moh','tamarind','awla','cashew','karanj'];
function Articles(){const t=useT(),{lang}=useLang();
  const a=useApp();
  return <Sec><Head t={t("Know your forest produce")} s={t("Short reads on what each one is and how to use it.")}/>
    <div className="fg" style={fgs(ART.length)}>{ART.map(k=>{const d=PACKS[lang].details?.[k]??D.find(x=>x.id===k),p=byId[k];return <div key={k} className="rc hs-a" onClick={()=>a.setModal({t:'art',k})}>
      <div className="im" style={{aspectRatio:'16/10'}}><Pic k={k} kind={p.k} col={p.c}/></div>
      <div className="nm" style={{fontSize:15}}>{t("{name}: what it is and how to use it",{name:d.name})}</div>
      <div className="rd">{d.about}</div><span className="lnk" style={{color:'var(--or)',textDecoration:'underline'}}>{t("Read more")}</span></div>})}</div></Sec>;
}

function Sell(){const t=useT();
  const L=[['Sign up','Register your Gram Sabha or yourself as a CFR villager. We check your details.','#/signup/gram-sabha'],['List what you have','Add the products you can give and about how much.','#/signup/villager/sell'],['Get requests','Buyers send requests. You accept, counter or say no, then hand over the goods.','#/signup']];
  return <Sec><Head t={t("Sell with VanRozgar")} s={t("Three steps to reach buyers across Nashik.")}/>
    <div className="fg" style={fgs(L.length)}>{L.map((x,i)=><div key={x[0]} className="st hs-s"><span className="hs-n">{i+1}</span><div className="nm" style={{fontSize:15}}>{t(x[0])}</div><div className="lc" style={{marginBottom:10}}>{t(x[1])}</div><button type="button" className="b1" onClick={()=>go(x[2])}>{t("Sign up")}</button></div>)}</div></Sec>;
}

const FAQ=[['Who sells on VanRozgar?','Gram Sabhas and CFR villagers in Nashik district. Every seller is checked before they list anything.'],['Do I pay on the site?','No. You send a request. The Gram Sabha answers it and confirms the final amount with you.'],['What does the price mean?','It is the price for the unit shown on the card, for example per kg or for 5 poles. Prices are shown before you ask.'],['How much stock is there?','Quantities on the pages are estimates. The Gram Sabha confirms what is ready.'],['What if the Gram Sabha offers less?','You get a counter offer in My requests. You can accept it or decline it.'],['Can I pick it up myself?','Yes. Choose pick-up in the request form, or ask for delivery to your address.'],['How do I follow my request?','Open My requests from the Account menu. You see every request and its status.'],['How do I sell my products?','Sign up as a Gram Sabha or CFR villager, then list the products you have. The Sell with VanRozgar steps above show how.']];
function Faq(){const t=useT();
  const [o,setO]=useState(0);
  return <Sec><Head c id="faq" t={t("Questions people ask")} s={t("Quick answers. Tap a question to open it.")}/>
    <div style={{maxWidth:820,margin:'0 auto'}}>{FAQ.map((f,i)=><div key={f[0]} style={{borderBottom:'1px solid var(--bd)',padding:'10px 0'}}>
      <button type="button" className="hs-q" aria-expanded={o===i} onClick={()=>setO(o===i?-1:i)}><span>{t(f[0])}</span><i className={`ti ti-chevron-${o===i?'up':'down'}`}></i></button>
      {o===i&&<div className="lc" style={{marginTop:6,fontSize:13.5}}>{t(f[1])}</div>}</div>)}</div></Sec>;
}

function AppBand(){const t=useT();
  const a=useApp();
  return <div className="band hs-app" style={{margin:'0 calc(-1 * var(--gut))',padding:'28px var(--gut)'}}><div className="row" style={{justifyContent:'space-between',alignItems:'center'}}>
    <div><h2 style={{fontSize:22}}>{t("Get the VanRozgar app")}</h2><p style={{margin:'4px 0 0'}}>{t("Shop and follow your requests from your phone.")}</p></div>
    <a className="b1" style={{textDecoration:'none',display:'inline-flex',alignItems:'center',gap:6,height:40,padding:'0 18px',borderRadius:8}} href={APK_URL} onClick={e=>{if(APK_URL==='#'){e.preventDefault();a.toast(t("The APK link will be added here."))}}}><i className="ti ti-download"></i> {t("Download the app")}</a></div></div>;
}

export default function HomeSections(){
  return <><Promos/><ShopVillages/><Groups/><Season/><How/><Why/><Impact/><Articles/><Sell/><Faq/><AppBand/></>;
}
