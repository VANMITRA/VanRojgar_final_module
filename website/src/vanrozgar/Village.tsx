import {useEffect} from 'react';
import {useApp} from './store';
import {M,PG,R} from './data';
import ResCard from './Card';
import {CAT,Chips,Foot,Kv,NQ,Pic,S,Tile,byId,nf} from './helpers';

export default function Village({v}:{v:string}){
  const a=useApp();
  useEffect(()=>{if(!R[v])location.hash='#/gram-sabhas'},[v]);
  if(!R[v])return null;
  const r=R[v],m=M[v],s=S[v],pg=PG[v];
  const its=s.filter(x=>a.cat==='All'||CAT[x[0]]===a.cat);const counted=pg.length&&pg[0][1]>0;
  const pill={textDecoration:'none',display:'inline-flex',alignItems:'center',gap:6,height:30,padding:'0 12px',borderRadius:8};
  return <>
    <div className="row" style={{justifyContent:'space-between',padding:'12px 0'}}><span className="lc">Home › <a href="#/gram-sabhas" style={{color:'var(--or)'}}>Gram Sabhas</a> › {v}</span><a className="b2" style={pill} href="#/gram-sabhas"><i className="ti ti-arrow-left"></i> All Gram Sabhas</a></div>
    <div className="band" style={{margin:'0 calc(-1 * var(--gut))',padding:'18px var(--gut)'}}><div className="row" style={{justifyContent:'space-between',alignItems:'flex-start'}}><div><h1 style={{margin:0}}>{v}</h1><div className="lc" style={{margin:'2px 0 8px'}}>{r[0]}, Nashik</div><div className="row"><span className="chip"><i className="ti ti-circle-check"></i> CFR title holder</span>{r[3]?<span className="chip">{r[3]} forest pond{r[3]>1?'s':''}</span>:null}{r[8]?<span className="chip">Wildlife sessions held</span>:null}<span className="chip">{r[7]} committee meeting{r[7]>1?'s':''}</span></div></div>
      <div className="row" style={{flexDirection:'column',alignItems:'stretch'}}><button className="b1" onClick={()=>a.toast('Jumps to the resources for sale.')}>Request from this village</button><button className="b2" onClick={()=>a.toast('The Gram Sabha has not added a phone number yet.')}><i className="ti ti-phone"></i> Call the Gram Sabha</button></div></div></div>
    <div className="g4" style={{padding:'14px 0'}}>{[[nf(r[1])+' ha','CFR area'],[nf(r[2]),'Saplings planted'],[s.length,'Products listed'],[m?m[3]+'%':'Not available yet','Forest share of the village']].map(x=><div key={x[1]} className="st"><div className="big">{x[0]}</div><div className="lc">{x[1]}</div></div>)}</div>
    <div className="sec"><h2>Resources for sale</h2><div className="sub">Quantities are estimates until the Gram Sabha enters its real stock.</div>
      {!s.length?<div className="st" style={{textAlign:'center'}}><b>No products listed yet</b><div className="lc">This Gram Sabha has not added its stock. Check back soon.</div></div>
      :<><div className="row" style={{marginBottom:10}}><Chips list={['All','Bamboo','Fruit','Nuts, seeds, flowers','Dry fruit and herbs']} sel={a.cat} onPick={a.setCat}/></div>
        {its.length?<div className="g4">{its.map(x=><ResCard key={x[0]} k={x[0]} v={v}/>)}</div>:<div className="lc">No resources in this group yet.</div>}</>}
</div>
    <div className="sec"><h2>Work done</h2><div className="sub">What this village has built and done for its forest.</div><div className="g4">{[[nf(r[1])+' ha','CFR area','Forest land the village holds rights over.'],[nf(r[2]),'Saplings planted','Planted and cared for so far.'],[r[3],'Forest ponds built','Ponds that hold water for animals and the forest.'],[nf(r[4]),'Water the ponds can hold','No unit is given.'],[r[5],'Loose boulder structures','Stone barriers that slow water and stop soil loss.'],[nf(r[6]),'Labour days','Days of work villagers did on planting and water works.'],[r[7],'Committee meetings','Meetings of the Community Forest Resource Management Committee.'],[r[8],'Wildlife sessions','Sessions that teach villagers about wildlife.']].map(x=><Tile key={x[1] as string} x={x}/>)}</div></div>
    <div className="sec"><h2>Plants growing here</h2>
      {!pg.length?<div className="st" style={{color:'var(--mut)'}}>Not available yet. There is no plant list for this village.</div>
      :<><div className="sub">{counted?`${pg.length} plants, ${nf(pg.reduce((x:number,y:any)=>x+y[1],0))} trees in the species list.`:`${pg.length} plant names are listed for this village, without counts.`}</div><div className="row" style={{marginBottom:8}}>{(a.allP?pg:pg.slice(0,10)).map((x:any)=><span key={x[0]} className="chip n">{x[0]}{counted?' · '+nf(x[1]):''}</span>)}</div>{pg.length>10&&<button className="b2" onClick={()=>a.setAllP(!a.allP)}>{a.allP?'Show fewer':'Show all '+pg.length+' plants'}</button>}</>}</div>
    <div className="sec"><h2>About the village</h2>
      {!m?<div className="st" style={{color:'var(--mut)'}}>Land and water data for this village is not available yet.</div>
      :<><div className="sub">Land, soil, water and roads, in simple words.</div><div className="g2">
        <div className="st"><b><i className="ti ti-trees"></i> Land and forest</b><Kv a="Village area" b={m[0]+' ha'}/><Kv a="Land parcels" b={nf(m[1])}/><Kv a="Forest" b={m[2]+' ha ('+m[3]+'%)'}/><Kv a="Forest type" b={m[4]}/><Kv a="Scrub and waste land" b={m[5]}/></div>
        <div className="st"><b><i className="ti ti-layers-subtract"></i> Soil</b><div style={{margin:'6px 0'}}>{m[6]}</div><div className="lc">{m[7]}</div></div>
        <div className="st"><b><i className="ti ti-droplet"></i> Water</b><Kv a="River" b={m[8]}/><Kv a="Streams" b={m[9]+' km'}/><Kv a="Water bodies" b={m[10]}/><Kv a="Wells" b={nf(m[11])}/><Kv a="Water works built" b={nf(m[12])}/></div>
        <div className="st"><b><i className="ti ti-road"></i> Roads and power</b><Kv a="Roads" b={m[13]}/><Kv a="Solar" b={m[14]}/></div></div></>}</div>
    <div className="sec"><h2>Contact</h2><div className="st row" style={{justifyContent:'space-between'}}><div style={{minWidth:220}}><Kv a="Contact person" b="Not added yet"/><Kv a="Phone" b="Not added yet"/><div className="lc" style={{marginTop:6}}>The Gram Sabha adds these in its profile.</div></div><button className="b2" onClick={()=>a.toast('The Gram Sabha has not added a phone number yet.')}><i className="ti ti-phone"></i> Call the Gram Sabha</button></div></div>
    
  </>;
}
