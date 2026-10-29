import {useApp} from '../store';
import {useT} from '../i18n';
import {useNeedLogin} from '../requests/common';
import MyRequests from '../requests/MyRequests';
import RequestDetail from '../requests/RequestDetail';
import Cart from '../Cart';
import Wishlist from '../Wishlist';
import Overview from './Overview';
import ProfileSettings from './ProfileSettings';
import {tabHref,tabsFor} from './tabs';

export default function Account({sub,id}:{sub:string,id:string}){
  const a=useApp(),t=useT(),out=useNeedLogin();
  if(out)return null;
  const tabs=tabsFor(a.role),cur=tabs.find(x=>x.id===sub)?.id||'overview';
  const body=cur==='requests'?(id?<RequestDetail id={id}/>:<MyRequests/>)
    :cur==='wishlist'?<Wishlist/>:cur==='cart'?<Cart/>:cur==='profile'?<ProfileSettings/>:<Overview/>;
  return <div className="acct">
    <nav className="acct-nav" aria-label={t('Account')}>{tabs.map(x=><a key={x.id} href={tabHref(x.id)} className={x.id===cur?'on':''} aria-current={x.id===cur?'page':undefined}><i className={`ti ti-${x.icon}`}></i><span>{t(x.label)}</span></a>)}</nav>
    <section className="acct-main">{body}</section>
  </div>;
}
