import {useEffect,useRef,useState} from 'react';
import './vanrozgar.css';
import {Ctx,Modal,CartLine,Profile} from './store';
import {LangProvider,useLangState} from './i18n';
import Legal,{ImpactTabs} from './Legal';
import Account from './account/Account';
import {SHOW_BARTER} from './helpers';
import Cart from './Cart';
import {useAutoGrid} from './autoGrid';
import SiteFooter from './SiteFooter';
import Wishlist from './Wishlist';
import Header from './Header';
import Home from './Home';
import Resources from './Resources';
import GramSabhas from './GramSabhas';
import Village from './Village';
import Barter from './Barter';
import Deliver from './Deliver';
import Impact from './Impact';
import Modals from './Modals';
import {MOCK_REQUESTS,Req} from './requests/mock';
import RequestForm from './requests/RequestForm';
import RequestSent from './requests/RequestSent';
import Login from './auth/Login';
import Signup from './auth/Signup';
import BuyerForm from './auth/BuyerForm';
import VillagerForm from './auth/VillagerForm';
import SellForm from './auth/SellForm';
import GramSabhaForm from './auth/GramSabhaForm';

const curOf=(h:string)=>h.replace(/^#\/?/,'').split('/')[0]||'';

export default function VanRozgarApp(){
  const [hash,setHash]=useState(location.hash);
  const [role,setRole]=useState('out'),[menu,setMenu]=useState(false),[cat,setCat]=useState('All'),[allP,setAllP]=useState(false);
  const [blk,setBlk]=useState('All'),[srt,setSrt]=useState('Most products'),[q,setQ]=useState(''),[metric,setMetric]=useState('Labour days');
  const [faq,setFaq]=useState(-1),[jt,setJt]=useState('Open jobs'),[sel,setSel]=useState(''),[modal,setModal]=useState<Modal>(null);
  const [theme,setTheme]=useState(()=>matchMedia('(prefers-color-scheme: dark)').matches?'dark':'light');
  const [reqs,setReqs]=useState<Req[]>(MOCK_REQUESTS);
  const [wish,setWish]=useState<string[]>([]),[cart,setCart]=useState<CartLine[]>([]);
  const lang=useLangState(),t=lang.t;
  const [phone,setPhone]=useState(''),[profile,setProfile]=useState<Profile>({name:'',email:'',address:'',village:''});
  const [msg,setMsg]=useState(''),tt=useRef<any>(0);
  const cur=curOf(hash);
  useAutoGrid();
  useEffect(()=>{
    if(cur==='barter'&&!SHOW_BARTER)location.hash='#/';
    if(cur==='terms'||cur==='privacy')location.hash='#/impact/'+cur;
  },[cur]);

  useEffect(()=>{const f=()=>{setHash(location.hash);if(curOf(location.hash)!=='resources')setSel('');setCat('All');setAllP(false);scrollTo(0,0)};
    addEventListener('hashchange',f);return()=>removeEventListener('hashchange',f)},[]);

  const toast=(t:string)=>{setMsg(t);clearTimeout(tt.current);tt.current=setTimeout(()=>setMsg(''),2600)};
  const toggleWish=(k:string)=>{const on=wish.includes(k);setWish(w=>on?w.filter(x=>x!==k):[...w,k]);toast(t(on?'Removed from Wishlist.':'Saved to Wishlist.'))};
  const addCart=(k:string,v:string)=>{setCart(c=>c.some(x=>x.k===k&&x.v===v)?c.map(x=>x.k===k&&x.v===v?{...x,n:x.n+1}:x):[...c,{k,v,n:1}]);toast(t('Added to cart. {village} Gram Sabha.',{village:v}))};
  const swapStart=(v?:string,id?:string)=>{if(role==='gs')setModal({t:'swap',v,id});else toast(t(role==='out'?'Log in as a Gram Sabha to start a swap.':'Barter is for Gram Sabha accounts.'))};

  const [a,b,c]=hash.replace(/^#\/?/,'').split('/');
  const page=a==='resources'?<Resources/>:a==='gram-sabhas'?<GramSabhas/>:a==='gram-sabha'?<Village v={decodeURIComponent(b||'')}/>:a==='barter'&&SHOW_BARTER?<Barter/>:a==='deliver'?<Deliver/>:a==='impact'?(b==='terms'||b==='privacy'?<div className="rq-page" style={{maxWidth:'none'}}><ImpactTabs cur={b}/><Legal kind={b}/></div>:<Impact/>):a==='request'?(b==='sent'?<RequestSent id={c||''}/>:<RequestForm pid={b||''} village={decodeURIComponent(c||'')}/>):a==='account'?<Account sub={b||''} id={c||''}/>:a==='my-requests'?<Account sub="requests" id={b||''}/>:a==='cart'?<Cart/>:a==='wishlist'?<Wishlist/>:a==='login'?<Login/>:a==='signup'?(b==='buyer'?<BuyerForm/>:b==='villager'?(c==='sell'?<SellForm/>:<VillagerForm/>):b==='gram-sabha'?<GramSabhaForm/>:<Signup/>):<Home/>;

  const bare=a==='login'||a==='signup';
  const ctx={role,setRole,menu,setMenu,cat,setCat,allP,setAllP,blk,setBlk,srt,setSrt,q,setQ,metric,setMetric,faq,setFaq,jt,setJt,sel,setSel,toast,modal,setModal,
    openP:(k:string,vn?:string)=>setModal({t:'plant',k,vn}),swapStart,reqs,setReqs,phone,setPhone,profile,setProfile,wish,toggleWish,cart,addCart,setCart,theme,toggleTheme:()=>setTheme(theme==='dark'?'light':'dark'),hash,cur};
  return <LangProvider value={lang}><Ctx.Provider value={ctx}><div className="vr" data-theme={theme} data-lang={lang.lang}>{bare?page:<><Header/><main className="wrap pg">{page}</main><SiteFooter/></>}<Modals/><div id="ts" style={{display:msg?'block':'none'}}>{msg}</div></div></Ctx.Provider></LangProvider>;
}
