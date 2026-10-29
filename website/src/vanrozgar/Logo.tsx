/* VanRozgar logo: white leaf on a green rounded square, then the word. */
export function LogoMark({size=28}:{size?:number}){
  return <svg width={size} height={size} viewBox="0 0 48 48" aria-hidden="true" style={{flex:`0 0 ${size}px`}}><rect width="48" height="48" rx="12" fill="#4E7A3A"/><path d="M14 33C14 23 21 16 34 15C34 26 28 33 18 33C16.5 33 15 32.8 14 32.4Z" fill="#F7F2E8"/><path d="M14 36C19 28 24 24 31 21" stroke="#4E7A3A" strokeWidth="2" fill="none" strokeLinecap="round"/></svg>;
}
export default function Logo({size=28}:{size?:number}){
  return <><LogoMark size={size}/><span>VanRozgar</span></>;
}
