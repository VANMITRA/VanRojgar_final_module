import {useApp} from './store';
import {S,VIL} from './helpers';

export default function SiteFooter(){
  const a=useApp();
  const top=[...VIL].sort((x,y)=>S[y].length-S[x].length).slice(0,4);
  const faq=()=>{if(location.hash.replace(/^#\/?/,'')!=='')location.hash='#/';setTimeout(()=>document.getElementById('faq')?.scrollIntoView({behavior:'smooth'}),60)};
  const info=(t:string)=>()=>a.toast(t);
  const L=(t:string,h:string)=><a key={t} href={h}>{t}</a>;
  const B=(t:string,f:()=>void)=><button key={t} type="button" onClick={f}>{t}</button>;
  const cols:[string,any[]][]=[
    ['01 // Resources',[L('All resources','#/resources'),L('Bamboo','#/resources'),L('Fruits','#/resources'),L('Nuts and oil seeds','#/resources'),L('Wishlist','#/wishlist'),L('Cart','#/cart')]],
    ['02 // Gram Sabhas',[L('All Gram Sabhas','#/gram-sabhas'),...top.map(v=>L(v,'#/gram-sabha/'+encodeURIComponent(v))),L('Our impact','#/impact')]],
    ['03 // Join us',[L('Sign up','#/signup'),L('Sell with VanMitra','#/signup/villager/sell'),L('Register a Gram Sabha','#/signup/gram-sabha'),L('Deliver with us','#/deliver'),L('Log in','#/login')]],
    ['04 // Help and about',[B('Questions people ask',faq),L('My requests','#/my-requests'),B('About VanMitra',info('About VanMitra opens here.')),B('Contact',info('Contact details open here.'))]],
  ];
  return <div className="sf" role="contentinfo"><div className="sf-in">
    <div className="sf-cols">{cols.map(([t,ls])=><div key={t}><h4>{t}</h4>{ls}</div>)}</div>
    <div className="sf-line"><span>&copy; {new Date().getFullYear()} VanMitra</span><span><a href="#/terms">{a.t('Terms of use')}</a> · <a href="#/privacy">{a.t('Privacy policy')}</a></span></div>
    <button type="button" className="sf-top" onClick={()=>scrollTo({top:0,behavior:'smooth'})}><i className="ti ti-arrow-up"></i> Back to top</button>
  </div><div className="sf-mark" aria-hidden="true">VANMITRA</div></div>;
}
