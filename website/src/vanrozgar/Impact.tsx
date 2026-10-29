import {useApp} from './store';
import {ImpactTabs} from './Legal';
import {R} from './data';
import {Chips,Foot,Tile,VIL,nf,sum,tv} from './helpers';
import {useT} from './i18n';

const mi:Record<string,number>={'Labour days':6,'Saplings planted':2,'Forest ponds':3,'Loose boulder structures':5};

export default function Impact(){const t=useT();
  const a=useApp();
  const ix=mi[a.metric],vs=VIL.slice().sort((x,y)=>R[y][ix]-R[x][ix]||x.localeCompare(y)),mx=Math.max(...vs.map(v=>R[v][ix]))||1;
  return <>
    <ImpactTabs cur=""/>
    <div className="band" style={{margin:'0 calc(-1 * var(--gut))',padding:'26px var(--gut)'}}><div className="eyebrow">{t("Our impact")}</div><h1>{t("What the villages have already done")}</h1><p style={{margin:0,maxWidth:560}}>{t("Numbers from the records of 14 Gram Sabhas in Nashik district. Sales numbers will show here once orders start.")}</p></div>
    <div className="sec" style={{border:0}}><h2>{t("Work done so far")}</h2><div className="sub">{t("Total across the 14 villages.")}</div><div className="g4">{[[nf(sum(0))+' ha','CFR area','Forest land the villages hold rights over.'],[nf(sum(1)),'Saplings planted','Planted and cared for so far.'],[sum(2),'Forest ponds built','Ponds that hold water for animals and the forest.'],[nf(sum(3)),'Water the ponds can hold','No unit is given.'],[nf(sum(4)),'Loose boulder structures','Stone barriers that slow water and stop soil loss.'],[nf(sum(5)),'Labour days','Days of work villagers did on planting and water works.'],[sum(6),'Committee meetings','Meetings of the Community Forest Resource Management Committee.'],[sum(7),'Wildlife sessions','Sessions that teach villagers about wildlife.']].map(x=><Tile key={x[1] as string} x={x}/>)}</div></div>
    <div className="sec"><h2>{t("Work by village")}</h2><div className="sub">{t("Pick what to compare.")}</div><div className="row" style={{marginBottom:10}}><Chips list={Object.keys(mi)} sel={a.metric} onPick={a.setMetric}/></div>{vs.map(v=><div key={v} className="bar"><div>{v}</div><div className="t"><i style={{width:`${Math.round(R[v][ix]/mx*100)}%`}}></i></div><div>{nf(R[v][ix])}</div></div>)}</div>
    <div className="sec"><h2>{t("What the villages could sell each year")}</h2><div className="sub">{t("Estimates for grown trees, based on the planting counts. Not sales.")}</div><div className="g5">{[['163,608','Bamboo poles'],['528,913 kg','Fresh fruit'],['257,775 kg','Moh flowers'],['80,491 kg','Nuts and seeds'],['242,760 kg','Dry fruit']].map(x=><div key={x[1]} className="st"><div className="big" style={{fontSize:17}}>{tv(x[0],t)}</div><div className="lc">{t(x[1])}</div></div>)}</div><div className="lc" style={{marginTop:8}}>{t("Kochargaon is not included because it has no plant counts. Assumes 70% of planted trees survive.")}</div></div>
    <div className="sec"><h2>{t("How every sale gives work to a village")}</h2><div className="g3" style={{marginTop:8}}>{[['ti-basket','Villagers prepare the produce','Harvesting, drying and packing is work for the village.'],['ti-users','The Gram Sabha manages the sale','It approves requests and keeps stock records.'],['ti-truck-delivery','Delivery partners carry it','Local vehicle owners earn from each trip.']].map(x=><div key={x[1]} className="st"><div className="ic"><i className={`ti ${x[0]}`}></i></div><b>{t(x[1])}</b><div className="meaning">{t(x[2])}</div></div>)}</div></div>
    <div className="sec"><h2>{t("VanRozgar so far")}</h2><div className="st" style={{marginTop:6}}><b>{t("Not started yet")}</b><div className="lc">{t("Orders, delivery jobs and money earned will show here once the first requests are approved.")}</div></div></div>
    
  </>;
}
