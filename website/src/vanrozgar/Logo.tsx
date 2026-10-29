/* VanRozgar logo: white leaf on a green rounded square, then the word. */
export function LogoMark(_:{size?:number}){
  return <img className="lm-img" src="/logo-192.png" alt="" width={40} height={40} decoding="async"/>;
}
export default function Logo({size=28}:{size?:number}){
  return <><LogoMark size={size}/><span>VanMitra</span></>;
}
