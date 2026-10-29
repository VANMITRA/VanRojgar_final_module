import Shell from './Shell';
import {Head} from './fields';
import {useT} from '../i18n';

const ROLES=[['building-community','Gram Sabha','Manage the village stock and approve requests','gram-sabha'],['home-2','CFR villager','Sell your own forest produce','villager'],['shopping-bag','General buyer','Buy forest produce from villages','buyer']];

export default function Signup(){const t=useT();
  return <Shell>
    <Head title={t("Sign up")} sub={t("I am a...")}/>
    {ROLES.map(r=><a key={r[3]} className="role" href={`#/signup/${r[3]}`}><div className="ic"><i className={`ti ti-${r[0]}`}></i></div><div><b>{t(r[1])}</b><span>{t(r[2])}</span></div></a>)}
    <div className="center" style={{marginTop:6}}>{t("Already have an account?")}<br/><a className="lk" href="#/login">{t("Login")}</a></div>
  </Shell>;
}
