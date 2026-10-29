import {useApp} from './store';
import {Foot} from './helpers';
import ResCard from './Card';
import {useT} from './i18n';

export default function Wishlist(){const t=useT();
  const a=useApp();
  return <div style={{padding:'20px 0 0'}}>
    <h1 style={{fontSize:26}}>{t("Wishlist")}</h1><div className="sub">{t("Resources you saved with the star.")}</div>
    {a.wish.length?<div className="g4" style={{marginTop:12}}>{a.wish.map(k=><ResCard key={k} k={k}/>)}</div>
    :<div className="st" style={{textAlign:'center',marginTop:12}}><div className="lc" style={{marginBottom:10}}>{t("Nothing saved yet. Tap the star on a card to save it.")}</div><button type="button" className="b1" onClick={()=>{location.hash='#/resources'}}>{t("Browse resources")}</button></div>}
    <Foot/>
  </div>;
}
