import {useApp} from './store';
import {Foot} from './helpers';
import ResCard from './Card';

export default function Wishlist(){
  const a=useApp();
  return <div style={{padding:'20px 0 0'}}>
    <h1 style={{fontSize:26}}>Wishlist</h1><div className="sub">Resources you saved with the star.</div>
    {a.wish.length?<div className="g4" style={{marginTop:12}}>{a.wish.map(w=>{const [k,v]=w.split('|');return <ResCard key={w} k={k} v={v}/>})}</div>
    :<div className="st" style={{textAlign:'center',marginTop:12}}><div className="lc" style={{marginBottom:10}}>Nothing saved yet. Tap the star on a card to save it.</div><button type="button" className="b1" onClick={()=>{location.hash='#/resources'}}>Browse resources</button></div>}
    <Foot/>
  </div>;
}
