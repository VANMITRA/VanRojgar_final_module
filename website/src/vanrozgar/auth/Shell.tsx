import {ReactNode} from 'react';
import {useApp} from '../store';
import Logo from '../Logo';
import {LangSwitch} from '../i18n';
import './auth.css';
import {useT} from '../i18n';

const art=<svg viewBox="0 0 300 250" aria-hidden="true"><ellipse cx="150" cy="120" rx="128" ry="104" fill="var(--b1)"/><ellipse cx="150" cy="128" rx="92" ry="74" fill="var(--b2)"/><rect x="64" y="176" width="172" height="9" rx="4" fill="#9CBF72"/><rect x="102" y="116" width="8" height="62" fill="#7B5232"/><circle cx="106" cy="100" r="34" fill="#6FA24A"/><circle cx="86" cy="116" r="22" fill="#86B85C"/><circle cx="128" cy="116" r="22" fill="#86B85C"/><circle cx="94" cy="96" r="5" fill="#E8873A"/><circle cx="118" cy="86" r="5" fill="#E8873A"/><circle cx="106" cy="114" r="5" fill="#E8873A"/><rect x="168" y="96" width="7" height="82" fill="#8DB85A"/><rect x="180" y="84" width="7" height="94" fill="#7FA84C"/><rect x="192" y="104" width="7" height="74" fill="#8DB85A"/><ellipse cx="164" cy="98" rx="13" ry="4" fill="#6FA24A" transform="rotate(-25 164 98)"/><ellipse cx="204" cy="106" rx="13" ry="4" fill="#6FA24A" transform="rotate(25 204 106)"/><rect x="208" y="150" width="34" height="26" fill="#C98F5B"/><polygon points="203,150 225,128 247,150" fill="#7B5232"/><rect x="221" y="160" width="9" height="16" fill="#8A5A36"/></svg>;

export default function Shell({children,login=false}:{children:ReactNode,login?:boolean}){const t=useT();
  const a=useApp();
  return <div className="au">
    <div className="au-tools"><button type="button" className="ib" aria-label={t("Switch theme")} onClick={a.toggleTheme}><i className={`ti ti-${a.theme==='dark'?'sun':'moon'}`}></i></button><LangSwitch/></div>
    <div className="lg">
      <div className="l">
        <a className="logo" href="#/"><Logo size={38}/></a>
        <div className="art"><div className="bub" style={{width:64,height:64,left:'6%',top:'8%',opacity:.55}}></div><div className="bub" style={{width:26,height:26,right:'8%',top:'18%',opacity:.7}}></div><div className="bub" style={{width:44,height:44,left:'12%',bottom:'6%',opacity:.5}}></div><div className="bub" style={{width:28,height:28,right:'14%',bottom:'12%',opacity:.6}}></div>{art}</div>
        <div className="tx"><b>{t("Forest goods, straight from the Gram Sabha")}</b><span>{login?t("Login to buy or sell forest produce."):t("Sign up to buy or sell forest produce.")}</span></div>
        <div className="cp">{t("© 2026 VanRozgar")}</div>
        <svg className="curve" viewBox="0 0 70 400" preserveAspectRatio="none" aria-hidden="true"><path d="M70 0V400H0C44 336 8 262 36 196S14 66 0 0Z" fill="var(--rp)"/></svg>
      </div>
      <div className="r">{children}
        <div className="foot"><span>{t("Need help? Contact the VanRozgar team")}</span><span><a className="lk" href="#/impact/terms" target="_blank" rel="noopener noreferrer">{t("Terms and conditions")}</a> · <a className="lk" href="#/impact/privacy" target="_blank" rel="noopener noreferrer">{t("Privacy policy")}</a></span></div></div>
    </div>
  </div>;
}
