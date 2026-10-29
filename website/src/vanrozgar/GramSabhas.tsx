import {useApp} from './store';
import {R} from './data';
import {Chips,Foot,Pic,S,VIL,byId,nf} from './helpers';
import {useT} from './i18n';

export default function GramSabhas(){const t=useT();
  const a=useApp();const q=a.q.trim().toLowerCase();
  let vs=VIL.filter(v=>(a.blk==='All'||R[v][0]===a.blk)&&(!q||v.toLowerCase().includes(q)));
  vs=a.srt==='A to Z'?vs.sort():vs.sort((x,y)=>S[y].length-S[x].length||x.localeCompare(y));
  return <>
    <div className="band" style={{margin:'0 calc(-1 * var(--gut))',padding:'22px var(--gut) 16px'}}><h1>{t("Gram Sabhas")}</h1><p style={{margin:'0 0 12px'}}>{t("14 villages in Nashik district that hold community forest rights. Pick one to see what it can sell.")}</p>
      <div className="search" style={{marginBottom:10}}><i className="ti ti-search"></i><input onChange={e=>a.setQ(e.target.value)} placeholder={t("Search by village name")} value={a.q}/></div>
      <div className="row" style={{justifyContent:'space-between'}}><div className="row"><Chips list={['All blocks','Deola','Dindori','Trimbakeshwar']} sel={a.blk==='All'?'All blocks':a.blk} onPick={c=>a.setBlk(c==='All blocks'?'All':c)}/></div><div className="row"><Chips list={['Most products','A to Z']} sel={a.srt} onPick={a.setSrt}/></div></div></div>
    <div className="sub" style={{marginTop:10}}>{t("Showing {n} of 14 Gram Sabhas",{n:vs.length})}</div>
    <div className="g2">{vs.length?vs.map(v=>{const r=R[v],s=S[v];return <div key={v} className="gc" onClick={()=>{location.hash='#/gram-sabha/'+encodeURIComponent(v)}}>
      <div><div style={{fontSize:17,fontWeight:500,color:'var(--h)'}}>{v}</div><div className="lc">{t("{taluka}, Nashik",{taluka:t(r[0])})}</div></div>
      {s.length?<div className="row" style={{gap:4}}>{s.slice(0,4).map(x=><div key={x[0]} className="mini"><Pic k={x[0]} kind={byId[x[0]].k} col={byId[x[0]].c}/></div>)}{s.length>4&&<span className="lc">{t("+{n} more",{n:s.length-4})}</span>}</div>:<div className="lc" style={{padding:'8px 0'}}>{t("No products listed yet")}</div>}
      <div className="row"><span className="chip"><i className="ti ti-circle-check"></i> {t("CFR title holder")}</span>{r[3]?<span className="chip n">{t(r[3]>1?"{n} forest ponds":"{n} forest pond",{n:r[3]})}</span>:null}</div>
      <div className="row" style={{justifyContent:'space-between',fontSize:12.5}}><span>{t(s.length===1?"{ha} ha CFR area · {n} product":"{ha} ha CFR area · {n} products",{ha:nf(r[1]),n:s.length})}</span><span style={{color:'var(--or)',fontWeight:500}}>{t("View village")} <i className="ti ti-arrow-right"></i></span></div></div>}):<div className="st" style={{gridColumn:'1/-1',textAlign:'center',color:'var(--mut)'}}>{t("No Gram Sabha matches your search. Try another name or block.")}</div>}</div>
    
  </>;
}
