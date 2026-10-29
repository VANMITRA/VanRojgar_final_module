import {useEffect} from 'react';
import {useApp} from './store';
import {M,PG,R} from './data';
import ResCard from './Card';
import {CAT,Chips,Foot,Kv,NQ,Pic,S,Tile,byId,nf,tv} from './helpers';
import {useT} from './i18n';

export default function Village({v}:{v:string}){const t=useT();
  const a=useApp();
  useEffect(()=>{if(!R[v])location.hash='#/gram-sabhas'},[v]);
  if(!R[v])return null;
  const r=R[v],m=M[v],s=S[v],pg=PG[v];
  const its=s.filter(x=>a.cat==='All'||CAT[x[0]]===a.cat);const counted=pg.length&&pg[0][1]>0;
  const pill={textDecoration:'none',display:'inline-flex',alignItems:'center',gap:6,height:30,padding:'0 12px',borderRadius:8};
  return <>
    <div className="row" style={{justifyContent:'space-between',padding:'12px 0'}}><span className="lc">{t("Home ›")} <a href="#/gram-sabhas" style={{color:'var(--or)'}}>{t("Gram Sabhas")}</a> › {v}</span><a className="b2" style={pill} href="#/gram-sabhas"><i className="ti ti-arrow-left"></i> {t("All Gram Sabhas")}</a></div>
    <div className="band" style={{margin:'0 calc(-1 * var(--gut))',padding:'18px var(--gut)'}}><div className="row" style={{justifyContent:'space-between',alignItems:'flex-start'}}><div><h1 style={{margin:0}}>{v}</h1><div className="lc" style={{margin:'2px 0 8px'}}>{t("{taluka}, Nashik",{taluka:t(r[0])})}</div><div className="row"><span className="chip"><i className="ti ti-circle-check"></i> {t("CFR title holder")}</span>{r[3]?<span className="chip">{t(r[3]>1?"{n} forest ponds":"{n} forest pond",{n:r[3]})}</span>:null}{r[8]?<span className="chip">{t("Wildlife sessions held")}</span>:null}<span className="chip">{t(r[7]>1?"{n} committee meetings":"{n} committee meeting",{n:r[7]})}</span></div></div>
      <div className="row" style={{flexDirection:'column',alignItems:'stretch'}}><button className="b1" onClick={()=>a.toast(t("Jumps to the resources for sale."))}>{t("Request from this village")}</button><button className="b2" onClick={()=>a.toast(t("The Gram Sabha has not added a phone number yet."))}><i className="ti ti-phone"></i> {t("Call the Gram Sabha")}</button></div></div></div>
    <div className="g4" style={{padding:'14px 0'}}>{[[nf(r[1])+' ha','CFR area'],[nf(r[2]),'Saplings planted'],[s.length,'Products listed'],[m?m[3]+'%':'Not available yet','Forest share of the village']].map(x=><div key={x[1]} className="st"><div className="big">{tv(x[0],t)}</div><div className="lc">{t(String(x[1]))}</div></div>)}</div>
    <div className="sec"><h2>{t("Resources for sale")}</h2><div className="sub">{t("Quantities are estimates until the Gram Sabha enters its real stock.")}</div>
      {!s.length?<div className="st" style={{textAlign:'center'}}><b>{t("No products listed yet")}</b><div className="lc">{t("This Gram Sabha has not added its stock. Check back soon.")}</div></div>
      :<><div className="row" style={{marginBottom:10}}><Chips list={['All','Bamboo','Fruit','Nuts, seeds, flowers','Dry fruit and herbs']} sel={a.cat} onPick={a.setCat}/></div>
        {its.length?<div className="g4">{its.map(x=><ResCard key={x[0]} k={x[0]} v={v}/>)}</div>:<div className="lc">{t("No resources in this group yet.")}</div>}</>}
</div>
    <div className="sec"><h2>{t("Work done")}</h2><div className="sub">{t("What this village has built and done for its forest.")}</div><div className="g4">{[[nf(r[1])+' ha','CFR area','Forest land the village holds rights over.'],[nf(r[2]),'Saplings planted','Planted and cared for so far.'],[r[3],'Forest ponds built','Ponds that hold water for animals and the forest.'],[nf(r[4]),'Water the ponds can hold','No unit is given.'],[r[5],'Loose boulder structures','Stone barriers that slow water and stop soil loss.'],[nf(r[6]),'Labour days','Days of work villagers did on planting and water works.'],[r[7],'Committee meetings','Meetings of the Community Forest Resource Management Committee.'],[r[8],'Wildlife sessions','Sessions that teach villagers about wildlife.']].map(x=><Tile key={x[1] as string} x={x}/>)}</div></div>
    <div className="sec"><h2>{t("Plants growing here")}</h2>
      {!pg.length?<div className="st" style={{color:'var(--mut)'}}>{t("Not available yet. There is no plant list for this village.")}</div>
      :<><div className="sub">{counted?t('{n} plants, {trees} trees in the species list.',{n:pg.length,trees:nf(pg.reduce((x:number,y:any)=>x+y[1],0))}):t('{n} plant names are listed for this village, without counts.',{n:pg.length})}</div><div className="row" style={{marginBottom:8}}>{(a.allP?pg:pg.slice(0,10)).map((x:any)=><span key={x[0]} className="chip n">{t(x[0])}{counted?' · '+nf(x[1]):''}</span>)}</div>{pg.length>10&&<button className="b2" onClick={()=>a.setAllP(!a.allP)}>{a.allP?t("Show fewer"):t('Show all {n} plants',{n:pg.length})}</button>}</>}</div>
    <div className="sec"><h2>{t("About the village")}</h2>
      {!m?<div className="st" style={{color:'var(--mut)'}}>{t("Land and water data for this village is not available yet.")}</div>
      :<><div className="sub">{t("Land, soil, water and roads, in simple words.")}</div><div className="g2">
        <div className="st"><b><i className="ti ti-trees"></i> {t("Land and forest")}</b><Kv a="Village area" b={m[0]+' ha'}/><Kv a="Land parcels" b={nf(m[1])}/><Kv a="Forest" b={m[2]+' ha ('+m[3]+'%)'}/><Kv a="Forest type" b={m[4]}/><Kv a="Scrub and waste land" b={m[5]}/></div>
        <div className="st"><b><i className="ti ti-layers-subtract"></i> {t("Soil")}</b><div style={{margin:'6px 0'}}>{tv(m[6],t)}</div><div className="lc">{tv(m[7],t)}</div></div>
        <div className="st"><b><i className="ti ti-droplet"></i> {t("Water")}</b><Kv a="River" b={m[8]}/><Kv a="Streams" b={m[9]+' km'}/><Kv a="Water bodies" b={m[10]}/><Kv a="Wells" b={nf(m[11])}/><Kv a="Water works built" b={nf(m[12])}/></div>
        <div className="st"><b><i className="ti ti-road"></i> {t("Roads and power")}</b><Kv a="Roads" b={m[13]}/><Kv a="Solar" b={m[14]}/></div></div></>}</div>
    <div className="sec"><h2>{t("Contact")}</h2><div className="st row" style={{justifyContent:'space-between'}}><div style={{minWidth:220}}><Kv a="Contact person" b="Not added yet"/><Kv a="Phone" b="Not added yet"/><div className="lc" style={{marginTop:6}}>{t("The Gram Sabha adds these in its profile.")}</div></div><button className="b2" onClick={()=>a.toast(t("The Gram Sabha has not added a phone number yet."))}><i className="ti ti-phone"></i> {t("Call the Gram Sabha")}</button></div></div>
    
  </>;
}
