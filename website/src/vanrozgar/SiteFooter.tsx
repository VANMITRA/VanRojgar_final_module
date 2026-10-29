import {useApp} from './store';
import {S,VIL} from './helpers';
import {useT} from './i18n';

export default function SiteFooter(){
  const a=useApp(),t=useT();
  const top=[...VIL].sort((x,y)=>S[y].length-S[x].length).slice(0,4);
  const faq=()=>{if(location.hash.replace(/^#\/?/,'')!=='')location.hash='#/';setTimeout(()=>document.getElementById('faq')?.scrollIntoView({behavior:'smooth'}),60)};
  const info=(x:string)=>()=>a.toast(t(x));
  const L=(x:string,h:string,raw=false)=><a key={x} href={h}>{raw?x:t(x)}</a>;
  const B=(x:string,f:()=>void)=><button key={x} type="button" onClick={f}>{t(x)}</button>;
  const cols:[string,any[]][]=[
    ['01 // Resources',[L('All resources','#/resources'),L('Bamboo','#/resources'),L('Fruits','#/resources'),L('Nuts and oil seeds','#/resources'),L('Wishlist','#/wishlist'),L('Cart','#/cart')]],
    ['02 // Gram Sabhas',[L('All Gram Sabhas','#/gram-sabhas'),...top.map(v=>L(v,'#/gram-sabha/'+encodeURIComponent(v),true)),L('Our impact','#/impact')]],
    ['03 // Join us',[L('Sign up','#/signup'),L('Sell with VanRozgar','#/signup/villager/sell'),L('Register a Gram Sabha','#/signup/gram-sabha'),L('Deliver with us','#/deliver'),L('Log in','#/login')]],
    ['04 // Help and about',[B('Questions people ask',faq),L('My requests','#/account/requests'),L('Terms and conditions','#/impact/terms'),L('Privacy policy','#/impact/privacy'),B('About VanRozgar',info('About VanRozgar opens here.')),B('Contact',info('Contact details open here.'))]],
  ];
  return <div className="sf" role="contentinfo"><div className="sf-in">
    <div className="sf-cols">{cols.map(([h,ls])=><div key={h}><h4>{t(h)}</h4>{ls}</div>)}</div>
    <div className="sf-line"><span>&copy; {new Date().getFullYear()} VanRozgar</span><span className="sf-legal"><a href="#/impact/terms">{t('Terms and conditions')}</a><a href="#/impact/privacy">{t('Privacy policy')}</a></span></div>
    <button type="button" className="sf-top" onClick={()=>scrollTo({top:0,behavior:'smooth'})}><i className="ti ti-arrow-up"></i> {t('Back to top')}</button>
  </div><div className="sf-mark" aria-hidden="true">VANROZGAR</div></div>;
}
