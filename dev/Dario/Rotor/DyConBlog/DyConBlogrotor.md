title: 
description:v
	
# The model

Consider a rotor rotating around a fixed axis. Because of wear and damage, the mass distribution is not homogeneous. This leads to dangerous vibrations in the rotation. A prototypical example can be a wind turbine, affected by misalignment of the blades and/or mass imbalance of the hub and blades [2].

In order to compensate the imbalance, two balancing heads are mounted at the endpoints of the axle, as in figure <a href="#1">1</a>. Each balancing head is made of two masses free to rotate.

Our goal is to determine the optimal movement of the balancing masses to minimize the vibrations. Control theoretical techniques are employed. For further details, see [6].
	<p id="1">![](spindlegrinder8mod.png) </p>
	<center> Figure <a href="#1">1</a>: representation of the rotor and the balancing. The balancing heads are located at the endpoints of the spindle. The four balancing masses (two for each balancing head) are drawn in red. </center>
	
Consider a rotor-fixed reference frame $(O;(x,y,z))$. Figures <a href="#1">1</a> and <a href="#2">2</a> show a front view of the device and a scheme of the balancing heads. 
	<p id="2">![](rotorfront.png) </p>
	<center>Figure <a href="#2">2</a>: front view of the system made of rotor and balancing device. </center>
	<p id="3">![](angles.png) </p>
	<center>Figure <a href="#3">3</a>: scheme of one balancing head. The balancing masses $(m_i,P_{i,1})$ and $(m_i,P_{i,2})$ are drawn in red. The bisector of the angle generated by $\overset{\longrightarrow}{OP_{i,1}}$ and $\overset{\longrightarrow}{OP_{i,2}}$ is the dashed line. The *intermediate* angle $\alpha_i$ is represented in <a href="#3">3</a>(A), while the *gap* angle $\gamma_i$ is depicted in <a href="#3">3</a>(B). The angles $\alpha_i$ and $\gamma_i$ give the position of the balancing masses in each balancing head. </center>
	
We consider two planes

$$ 
\pi_1:= \left\{z=-a\right\} \quad \text{and} \quad \pi_2\coloneqq \left\{z=b\right\},\quad a,b,\geq 0
$$
orthogonal to the rotation axis $z$. The balancing device (see figures <a href="#1">1</a> and <a href="#2">2</a>) is made of two heads lying in each of these planes. 

The heads are fixed to the rotor and rotate with it. In particular, $\alpha_i$ and $\gamma_i$ are defined with respect to the rotor-fixed reference frame $(O;(x,y,z))$.

Each head is made of a pair of balancing masses, which are free to rotate orthogonally to the rotation axis $z$.  

Namely, we have
* 
<!-- WARNING: We should put $(a,b)\in\mathbb{R}^2$. -->
* two mass-points $(m_1,P_{1,1})$ and $(m_1,P_{1,2})$ lying on $\pi_1$ at distance $r_1$ from the axis $z$, i.e., in the reference frame $(O;(x,y,z))$
$$
\begin{cases}
P_{1,1;x}=&r_1\cos(\alpha_1-\gamma_1)\\
P_{1,1;y}=&r_1\sin(\alpha_1-\gamma_1)\\
P_{1,1;z}=&-a,\\
\end{cases}
\hspace{0.3 cm}\text{and}\hspace{0.3 cm}
\begin{cases}
P_{1,2;x}=&r_1\cos(\alpha_1+\gamma_1)\\
P_{1,2;y}=&r_1\sin(\alpha_1+\gamma_1)\\
P_{1,2;z}=&-a;\\
\end{cases}$$
* two mass-points $(m_2,P_{2,1})$ and $(m_2,P_{2,2})$ lying on $\pi_2$ at distance $r_2$ from the axis $z$, namely, in the reference frame $(O;(x,y,z))$
$$\begin{cases}
		P_{2,1;x}=&r_2\cos(\alpha_2-\gamma_2)\\
		P_{2,1;y}=&r_2\sin(\alpha_2-\gamma_2)\\
		P_{2,1;z}=&b,\\
		\end{cases}
		\hspace{0.3 cm}\text{and}\hspace{0.3 cm}
		\begin{cases}
		P_{2,2;x}=&r_2\cos(\alpha_2+\gamma_2)\\
		P_{2,2;y}=&r_2\sin(\alpha_2+\gamma_2)\\
		P_{2,2;z}=&b.\\
		\end{cases}$$

For any $i=1,2$, let $b_i$ be the bisector of the angle generated by $\overset{\longrightarrow}{OP_{i,1}}$ and $\overset{\longrightarrow}{OP_{i,2}}$ (see figure <a href="#3">3</a>). The *intermediate* angle $\alpha_i$ is the angle between the $x$-axis and the bisector $b_i$, while the *gap* angle $\gamma_i$ is the angle between $\overset{\longrightarrow}{OP_{i,1}}$ and the bisector $b_i$.
	
The imbalance is modelled by a resulting force $F$ and a momentum $N$ orthogonal to the rotation axis. In the rotor-fixed reference frame $(O;(x,y,z))$, set $P_1\coloneqq (0,0,-a)$, $P_2\coloneqq (0,0,b)$, $F\coloneqq (F_x,F_y,0)$ and $N\coloneqq (N_x,N_y,0)$. By imposing the equilibrium condition on forces and momenta, the force $F$ and the momentum $N$ can be decomposed into a force $F_1$ exerted at $P_1$ contained in plane $\pi_1$ and a force $F_2$ exerted at $P_2$ contained in $\pi_2$.
	
In each plane, we generate a force to balance the system, by moving the balancing masses:
* in the plane $\pi_1$, we compensate $F_1$ by the centrifugal force:
$$
B_1=m_1r_1\omega^2\left(\cos(\alpha_1-\gamma_1)+\cos(\alpha_1+\gamma_1),\sin(\alpha_1-\gamma_1)+\sin(\alpha_1+\gamma_1)\right);$$
* in the plane $\pi_2$, we compensate $F_2$ by the centrifugal force:
$$
		B_2=m_2r_2\omega^2\left(\cos(\alpha_2-\gamma_2)+\cos(\alpha_2+\gamma_2),\sin(\alpha_2-\gamma_2)+\sin(\alpha_2+\gamma_2)\right);	
$$
	
The overall imbalance of the system is then given by the resulting forces in $\pi_1$ and $\pi_2$, 
$$
	F_{ris,1}=B_1+F_1
$$
and 
$$
	F_{ris,2}=B_2+F_2,
$$
respectively.

The overall imbalance on the system made of rotor and balancing device is measured by the imbalance indicator
$$
	G=\|B_1+F_1\|^2+\|B_2+F_2\|^2.
$$
	
Our task is to find a control strategy such that
* the balancing masses move from their initial configuration $\Phi_0$ to a final configuration $\overline{\Phi}$, where the imbalance is compensated;
* the imbalance and velocities should be kept small during the correction process.
	
We address the minimization problem
$$
	\min_{\Phi\in\mathscr{A}} \frac{1}{2}\int_0^{\infty} \left[\|\Phi'\|^2+{\beta}Q(\Phi)\right] dt,\hspace{0.6 cm}(M)
$$
where $Q(\Phi)\coloneqq G(\Phi)-\inf G$ and
$$
	\mathscr{A}\coloneqq \left\{\Phi\in H^1_{loc}((0,+\infty);\mathbb{T}^4) \hspace{0.3 cm} \big| \hspace{0.3 cm} \Phi(0)=\Phi_0,\hspace{0.3 cm}and\hspace{0.3 cm}L(\Phi,\Phi')\in L^1(0,+\infty)\right\},
$$
with $H^1_{loc}((0,+\infty);\mathbb{T}^4)\coloneqq \cap_{T>0}H^1(0,T;\mathbb{T}^4)$.

The theoretical analysis of the above problem is in [6]. The existence of the optimum is proved. The stabilization of the optimal trajectories towards steady optima is proved in any condition.

# Simulation
	
In order to perform some numerical simulations, we firstly discretize our cost functional and then we run AMPL-IPOpt to minimize the resulting discretized functional.

For the purpose of the numerical simulations, it is convenient to rewrite the cost functional as
$$
{K}\left(\psi,\Phi\right) \coloneqq \int_0^{\infty}\frac12 \|\Phi'\|^2+Q\left(\Phi\right)dt,
$$
subject to the state equation
$$
\begin{dcases}
\Phi'=\psi\hspace{0.6 cm} &t\in (0,+\infty)\\
\Phi(0)=\Phi_0.\\
\end{dcases}
$$

## Discetization
Choose $T$ sufficiently large and $Nt\in\mathbb{N}\setminus \left\{0,1\right\}$. Set $\Delta t\coloneqq \frac{T}{Nt-1}$. The discretized state is $\left(\Phi_i\right)_{i=0,\dots,Nt-1}$, whereas the discretized control (velocity) is $\left(\psi_{i}\right)_{i=0,\dots,Nt-2}$. The discretized functional then reads as
$${K_d}\left(\psi,\Phi\right) \coloneqq \Delta t\sum_{i=0}^{Nt-1}\left[\frac12 \|\psi_i\|^2+Q\left(\Phi_i\right)\right],$$
subject to the state equation
$$\frac{\Phi_i-\Phi_{i-1}}{\Delta t}=\psi_{i-1},\hspace{0.3 cm}i=1,\dots,Nt-1,\hspace{0.6 cm}\text{(D)}$$

## Execution

The discretized minimization problem is
$$
\text{minimize}\hspace{0.3 cm}{K_d},\hspace{0.3 cm}\text{subject to (D)}.
$$
We address the above minimization problem by employing the interior-point optimization routine IPOpt (see [3,4]) coupled with AMPL [1], which serves as modelling language and performs the automatic differentiation. The interested reader is referred to [6, Chapter 9] and [7] for a survey on existing numerical methods to solve an optimal control problem.

In figures <a href="#4">4</a>, <a href="#5">5</a>, <a href="#6">6</a> and <a href="#7">7</a>, we plot the computed optimal trajectory for \eqref{functional}, with initial datum $\Phi_0=\left(\alpha_{0,1},\gamma_{0,1};\alpha_{0,2},\gamma_{0,2}\right)\coloneqq \left(2.6,0.6, 2.5,1.5\right)$. We choose $F$, $N$ and $m_i$, such that the condition \eqref{prop_group_eq4} is fulfilled. The exponential stabilization proved in [6] emerges. 
    <p id="4">![](optstabilalpha1.png) </p>
	<center>Figure <a href="#4">4</a>: intermediate angle $\alpha_1$ versus time. </center>
	<p id="5">![](optstabilgamma1.png) </p>
	<center>Figure <a href="#5">5</a>: gap angle $\gamma_1$ versus time. </center>
	<p id="6">![](optstabilalpha2.png) </p>
	<center> Figure <a href="#6">6</a>: intermediate angle $\alpha_2$ versus time. </center>
In figure <a href="#8">8</a>, we depict the imbalance indicator versus time along the computed trajectories. As expected, it decays to zero exponentially.
	<p id="7">![](optstabilgamma2.png) </p>
	<center>Figure <a href="#7">7</a>: gap angle $\gamma_2$ versus time. </center>
	<p id="8">![](systemresponse.png) </p>
	<center> Figure <a href="#8">8</a>: system response. </center>

# References:
[1] Robert Fourer, David M Gay, and Brian W Kernighan. A modeling language for mathematical programming. Management Science, 36(5):519{554, 1990.

[2] Mike Jeffrey, Michael Melsheimer, and Jan Liersch. Method and system for determining an imbalance of a wind turbine rotor, September 11 2012. US Patent 8,261,599.

[3] Andreas Waechter, Carl Laird, F Margot, and Y Kawajir. Introduction to ipopt: A tutorial for downloading, installing, and using ipopt. Revision, 2009.

[4] Andreas Waechter and Lorenz T Biegler. On the implementation of an interior-point lterline-search algorithm for large-scale nonlinear programming. Mathematical programming, 106(1):25{57, 2006.

[6] \cite{RIO}

[7] Noboru Sakamoto and Arjan J van der Schaft. Analytical approximation methods for the stabilizing solution of the Hamilton-Jacobi equation. IEEE Transactions on Automatic Control, 53(10):2335{2350, 2008.

[7] Emmanuel Trélat. Contrôle optimal : théorie et applications
Mathématiques Concrètes. Vuibert, Paris, 2005. available
online:
https://www.ljll.math.upmc.fr/trelat/chiers/livreopt2.pdf.