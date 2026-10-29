import {useApp} from './store';
import {O,P} from './data';
import {TOP,byId,Pic,Foot} from './helpers';
import {Card} from './Home';
import {CategoryBoxes} from './Card';
import {useT} from './i18n';

export default function Resources(){const t=useT();
  const a=useApp();
  const ord=a.sel?[a.sel].concat(TOP.filter(x=>x!==a.sel)):TOP;
  const scroll=(id:string,d:number)=>document.getElementById('r-'+id)?.scrollBy({left:d,behavior:'smooth'});
  return <>
    <div style={{padding:'20px 0 6px'}}><h1 style={{fontSize:26}}>{t("All resources")}</h1><div className="sub">{a.sel?t("Showing {name} first. ",{name:t(byId[a.sel].n)}):t("Plants from Gram Sabhas in Nashik. ")}{t("Scroll each row sideways.")}</div></div>
    {ord.map(id=>{const p=byId[id];return <div key={id} style={{marginBottom:8}}><div className="row" style={{justifyContent:'space-between',padding:'6px 0'}}><div><b style={{fontSize:16,color:'var(--h)',fontWeight:500}}>{t(p.n)}</b> <span className="sub">{t("in {n} Gram Sabhas",{n:p.v.length})}</span></div><div className="row" style={{gap:6}}><button className="b2 ib" aria-label={t("Scroll left")} onClick={()=>scroll(id,-340)}><i className="ti ti-chevron-left"></i></button><button className="b2 ib" aria-label={t("Scroll right")} onClick={()=>scroll(id,340)}><i className="ti ti-chevron-right"></i></button></div></div><div className="shelf" id={`r-${id}`}>{p.v.map((r:any)=><Card key={r[0]} p={p} r={r} q/>)}</div></div>})}
    <div className="sec"><h2>{t("All resources ({n})",{n:P.length+O.length})}</h2><div className="sub">{t("Tap a card to see where it grows.")}</div><CategoryBoxes/></div><Foot/>
  </>;
}
