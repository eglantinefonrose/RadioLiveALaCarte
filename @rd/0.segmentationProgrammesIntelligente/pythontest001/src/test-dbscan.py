from __future__ import print_function

from sklearn.datasets import make_blobs
from sklearn.preprocessing import StandardScaler

from sklearn.cluster import DBSCAN

centers = [[1, 1], [-1, -1], [1, -1]]
X, labels_true = make_blobs(
    n_samples=750, centers=centers, cluster_std=0.4, random_state=0
)

X = StandardScaler().fit_transform(X)

db = DBSCAN(eps=0.3, min_samples=10).fit(X)
labels = db.labels_

#plt.scatter(X[:, 0], X[:, 1])
#plt.show()
transitions = []
for i in range(0, len(labels)-1):
    if labels[i] != labels[i + 1]:  # Si le label change
        print(i)