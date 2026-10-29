import {useApp} from './store';
import HeroBanner from './HeroBanner';
import HomeSections from './HomeSections';
import ResCard from './Card';
import {fgs,APK_URL,CIR,TOP,byId,loc,Pic,Foot} from './helpers';

const FEAT=[...TOP,'Ritha','Kawath'];

export function Card({p,r}:{p:any,r?:any,q?:boolean}){return <ResCard k={p.i} v={r?r[0]:undefined}/>}

export default function Home(){
  const a=useApp();
  const go=(h:string)=>{location.hash=h};
  return <>
    <HeroBanner eager cls="hb-up" src="assets/images/hero-home.jpg" alt="Three villagers holding baskets of awla, tamarind and mangoes in a forest"><div className="eyebrow">From traditional villages to your home</div><h1>Authentic forest goods, direct from India’s Gram Sabhas.</h1><p style={{margin:'0 0 16px'}}>Discover resources near you, see real-time distance and transparent pricing, and purchase direct. Every sale empowers a village community.</p>
      <div className="row" style={{marginBottom:14}}><button className="b1" onClick={()=>go('#/resources')}>Shop forest resources <i className="ti ti-arrow-right"></i></button><a className="b2" style={{textDecoration:'none',display:'inline-flex',alignItems:'center',gap:6,height:36,padding:'0 14px',borderRadius:8}} href={APK_URL} onClick={e=>{if(APK_URL==='#'){e.preventDefault();a.toast('The APK link will be added here.')}}}><i className="ti ti-download"></i> Get the mobile app</a></div>
      <div className="row" style={{gap:16,fontSize:13}}><span><i className="ti ti-shield-check" style={{color:'var(--g)'}}></i> Verified source</span><span><i className="ti ti-map-pin" style={{color:'var(--g)'}}></i> Distance-shown</span><span><i className="ti ti-tag" style={{color:'var(--g)'}}></i> Fair pricing</span></div></HeroBanner>
    <div className="circ">{CIR.map(id=>{const p=byId[id];return <div key={id} onClick={()=>{a.setSel(id);go('#/resources')}}><div className="c"><Pic k={id} kind={p.k} col={p.c}/></div>{p.n}</div>})}<div onClick={()=>a.setModal({t:'all'})}><div className="c" style={{background:'var(--tint)',fontSize:26,color:'var(--or)'}}><i className="ti ti-dots"></i></div>More</div></div>
    <div className="row" style={{justifyContent:'space-between',marginBottom:8}}><h2>Featured resources</h2><a style={{color:'var(--or)',cursor:'pointer'}} onClick={()=>go('#/resources')}>Explore more <i className="ti ti-arrow-right"></i></a></div>
    <div className="fg" style={fgs(FEAT.length)}>{FEAT.map(k=><ResCard key={k} k={k}/>)}</div>
    <div style={{textAlign:'center',padding:'20px 0 4px'}}><button className="b1" style={{padding:'0 24px'}} onClick={()=>go('#/resources')}>Explore more resources <i className="ti ti-arrow-right"></i></button></div><HomeSections/>
  </>;
}
