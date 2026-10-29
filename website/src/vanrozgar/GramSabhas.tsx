import {useApp} from './store';
import {R} from './data';
import {Chips,Foot,Pic,S,VIL,byId,nf} from './helpers';

export default function GramSabhas(){
  const a=useApp();const q=a.q.trim().toLowerCase();
  let vs=VIL.filter(v=>(a.blk==='All'||R[v][0]===a.blk)&&(!q||v.toLowerCase().includes(q)));
  vs=a.srt==='A to Z'?vs.sort():vs.sort((x,y)=>S[y].length-S[x].length||x.localeCompare(y));
  return <>
    <div className="band" style={{margin:'0 calc(-1 * var(--gut))',padding:'22px var(--gut) 16px'}}><h1>Gram Sabhas</h1><p style={{margin:'0 0 12px'}}>14 villages in Nashik district that hold community forest rights. Pick one to see what it can sell.</p>
      <div className="search" style={{marginBottom:10}}><i className="ti ti-search"></i><input onChange={e=>a.setQ(e.target.value)} placeholder="Search by village name" value={a.q}/></div>
      <div className="row" style={{justifyContent:'space-between'}}><div className="row"><Chips list={['All blocks','Deola','Dindori','Trimbakeshwar']} sel={a.blk==='All'?'All blocks':a.blk} onPick={c=>a.setBlk(c==='All blocks'?'All':c)}/></div><div className="row"><Chips list={['Most products','A to Z']} sel={a.srt} onPick={a.setSrt}/></div></div></div>
    <div className="sub" style={{marginTop:10}}>Showing {vs.length} of 14 Gram Sabhas</div>
    <div className="g2">{vs.length?vs.map(v=>{const r=R[v],s=S[v];return <div key={v} className="gc" onClick={()=>{location.hash='#/gram-sabha/'+encodeURIComponent(v)}}>
      <div><div style={{fontSize:17,fontWeight:500,color:'var(--h)'}}>{v}</div><div className="lc">{r[0]}, Nashik</div></div>
      {s.length?<div className="row" style={{gap:4}}>{s.slice(0,4).map(x=><div key={x[0]} className="mini"><Pic k={x[0]} kind={byId[x[0]].k} col={byId[x[0]].c}/></div>)}{s.length>4&&<span className="lc">+{s.length-4} more</span>}</div>:<div className="lc" style={{padding:'8px 0'}}>No products listed yet</div>}
      <div className="row"><span className="chip"><i className="ti ti-circle-check"></i> CFR title holder</span>{r[3]?<span className="chip n">{r[3]} forest pond{r[3]>1?'s':''}</span>:null}</div>
      <div className="row" style={{justifyContent:'space-between',fontSize:12.5}}><span>{nf(r[1])} ha CFR area · {s.length} product{s.length===1?'':'s'}</span><span style={{color:'var(--or)',fontWeight:500}}>View village <i className="ti ti-arrow-right"></i></span></div></div>}):<div className="st" style={{gridColumn:'1/-1',textAlign:'center',color:'var(--mut)'}}>No Gram Sabha matches your search. Try another name or block.</div>}</div>
    
  </>;
}
