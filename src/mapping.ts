import {
  PepeBorn,
  Transfer,
  PepeResurrected,
  UserNamed,
  SetPepeNameCall
} from "../generated/PepeReborn/PepeReborn"
import { 
  NfpStat as Nfp, 
  Pepe, 
  User 
} from "../generated/schema"

const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000'

function getOrCreateNfp(): Nfp {
  let nfp = Nfp.load(ZERO_ADDRESS)

  if(nfp == null) {
    nfp = new Nfp(ZERO_ADDRESS)
    nfp.resurrectedCnt = 0
    nfp.bornCnt = 0
    nfp.mintedCnt = 0
    nfp.burnedCnt = 0
    nfp.pepeNamedCnt = 0
    nfp.userNamedCnt = 0
    nfp.pepeRenouncedCnt = 0
    nfp.pepeTransferCnt = 0
  }

  return nfp as Nfp
}

function getOrCreateUser(id: string): User {
  let user = User.load(id)

  if (user == null) {
    user = new User(id)
  }

  return user as User
}

export function handlePepeBorn(event: PepeBorn): void {
  let fatherId = event.params.father.toHex()
  let motherId = event.params.mother.toHex()
  let pepeId = event.params.pepeId.toHex()

  let pepe = Pepe.load(pepeId)

  let nfp = getOrCreateNfp()
  let born = nfp.bornCnt

  if (pepe == null) {
    pepe = new Pepe(pepeId)
    pepe.isBurned = false
    pepe.isReborn = false
  }

  let isMintMother = motherId == '0x0'
  let isMintFather = motherId == '0x0'

  if (isMintFather && isMintMother) {
    pepe.isGenZero = true
  } else {
    pepe.isGenZero = false
    pepe.mother = motherId
    pepe.father = fatherId
  }

  nfp.bornCnt = born + 1

  nfp.save()
  pepe.save()
}

export function handleSetPepeName(call: SetPepeNameCall): void {
  let pepeId = call.inputs.pepeId.toHex()
  let name = call.inputs._name.toString()

  let pepe = Pepe.load(pepeId)
  let nfp = getOrCreateNfp()
  let cnt = nfp.pepeNamedCnt

  pepe.name = name
  nfp.pepeNamedCnt = cnt + 1

  nfp.save()
  pepe.save()
}

export function handleTransfer(event: Transfer): void {
  let pepeId = event.params.pepeId.toHex()
  let fromId = event.params._from.toHex()
  let toId = event.params._to.toHex()

  let isMint = fromId == ZERO_ADDRESS
  let isBurn = toId == ZERO_ADDRESS

  let nfp = getOrCreateNfp()
  let minted = nfp.mintedCnt
  let burned = nfp.burnedCnt
  let transfer = nfp.pepeTransferCnt

  let pepe = Pepe.load(pepeId)

  if (isMint) {
    nfp.mintedCnt = minted + 1
  } else if (isBurn) {
    nfp.burnedCnt = burned + 1
    pepe.isBurned = true
  } else {
    nfp.pepeTransferCnt = transfer + 1
  }

  pepe.owner = toId

  pepe.save()
  nfp.save()
}

export function handlePepeResurrected(event: PepeResurrected): void {
  let pepeId = event.params.pepeId.toHex()
  let pepe = Pepe.load(pepeId)
  pepe.isReborn = true

  let nfp = getOrCreateNfp()
  let resurrected = nfp.resurrectedCnt

  nfp.resurrectedCnt = resurrected + 1

  nfp.save()
  pepe.save()
}

export function handleUserNamed(event: UserNamed): void {
  let userId = event.params.user.toHex()
  let userName = event.params.username.toString()
  let nfp = getOrCreateNfp()
  let cnt = nfp.userNamedCnt

  let user = getOrCreateUser(userId)
  user.name = userName

  nfp.userNamedCnt = cnt + 1

  user.save()
  nfp.save()
}
